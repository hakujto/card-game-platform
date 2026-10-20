package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeDisputeHandler struct { db *gorm.DB }

func NewTradeDisputeHandler(db *gorm.DB) *TradeDisputeHandler {
	return &TradeDisputeHandler{db: db}
}

func (h *TradeDisputeHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/trade_disputes")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/api/disputes/{id}/escalate", h.Escalate)
	g.Post("/:id/api/disputes/{id}/resolve", h.Resolve)
	g.Post("/:id/api/disputes/{id}/close", h.CloseResolved)
	g.Post("/:id/api/disputes/{id}/review", h.Review)
	g.Patch("/:id/transitions/open-to-underreview", h.TransitionOpenToUnderReview)
	g.Patch("/:id/transitions/underreview-to-resolved", h.TransitionUnderReviewToResolved)
	g.Patch("/:id/transitions/underreview-to-escalated", h.TransitionUnderReviewToEscalated)
	g.Patch("/:id/transitions/escalated-to-resolved", h.TransitionEscalatedToResolved)
	g.Patch("/:id/transitions/resolved-to-open", h.TransitionResolvedToOpen)
}

func (h *TradeDisputeHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeDispute
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TradeDisputeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TradeDisputeHandler) Create(c *fiber.Ctx) error {
	var req model.TradeDisputeCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTradeDispute(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TradeDispute{}
	row.Status = req.Status
	row.Reason = req.Reason
	row.Description = req.Description
	row.Resolution = req.Resolution
	row.OpenedAt = req.OpenedAt
	row.ResolvedAt = req.ResolvedAt
	row.TransactionID = req.TransactionID
	row.OpenedByID = req.OpenedByID
	row.ResolvedByID = req.ResolvedByID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) Escalate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	err := row.Escalate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeDisputeHandler) Resolve(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesResolve := []string{"admin", "moderator"}
	roleOkResolve := false
	for _, r := range allowedRolesResolve { if r == userRole { roleOkResolve = true; break } }
	if !roleOkResolve { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for resolve"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	resolutionText := func() string {
		v, ok := body["resolution_text"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Resolve(resolutionText)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeDisputeHandler) CloseResolved(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	err := row.CloseResolved()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeDisputeHandler) Review(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	err := row.Review()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeDisputeHandler) TransitionOpenToUnderReview(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionOpenToUnderReview := []string{"Admin", "Moderator"}
	roleOkTransitionOpenToUnderReview := false
	for _, r := range allowedRolesTransitionOpenToUnderReview { if r == userRole { roleOkTransitionOpenToUnderReview = true; break } }
	if !roleOkTransitionOpenToUnderReview { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Open -> UnderReview"}) }
	if err := row.AssertTransition("UnderReview"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TradeDisputeStatusType_UnderReview
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Review() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionUnderReviewToResolved(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionUnderReviewToResolved := []string{"Admin", "Moderator"}
	roleOkTransitionUnderReviewToResolved := false
	for _, r := range allowedRolesTransitionUnderReviewToResolved { if r == userRole { roleOkTransitionUnderReviewToResolved = true; break } }
	if !roleOkTransitionUnderReviewToResolved { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition UnderReview -> Resolved"}) }
	if err := row.AssertTransition("Resolved"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.Resolution == nil {
		return handler.UnprocessableError(c, "resolution is required for this transition")
	}
	row.Status = model.TradeDisputeStatusType_Resolved
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.CloseResolved() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionUnderReviewToEscalated(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionUnderReviewToEscalated := []string{"Admin"}
	roleOkTransitionUnderReviewToEscalated := false
	for _, r := range allowedRolesTransitionUnderReviewToEscalated { if r == userRole { roleOkTransitionUnderReviewToEscalated = true; break } }
	if !roleOkTransitionUnderReviewToEscalated { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition UnderReview -> Escalated"}) }
	if err := row.AssertTransition("Escalated"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TradeDisputeStatusType_Escalated
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Escalate() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionEscalatedToResolved(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionEscalatedToResolved := []string{"Admin"}
	roleOkTransitionEscalatedToResolved := false
	for _, r := range allowedRolesTransitionEscalatedToResolved { if r == userRole { roleOkTransitionEscalatedToResolved = true; break } }
	if !roleOkTransitionEscalatedToResolved { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Escalated -> Resolved"}) }
	if err := row.AssertTransition("Resolved"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.Resolution == nil {
		return handler.UnprocessableError(c, "resolution is required for this transition")
	}
	row.Status = model.TradeDisputeStatusType_Resolved
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.CloseResolved() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionResolvedToOpen(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeDispute") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Resolved -> Open is not allowed")
}

// ── Validation rules ─────────────────────────────────────────────
func validateTradeDispute(req *model.TradeDisputeCreateRequest) []string {
	var errs []string
	if !((!( req.ResolvedAt != nil ) || (req.Status == model.TradeDisputeStatusType_Resolved))) {
		errs = append(errs, "resolved_at_requires_terminal_status")
	}
	return errs
}

func toCreateRequestTradeDispute(m *model.TradeDispute) model.TradeDisputeCreateRequest {
	return model.TradeDisputeCreateRequest{
		Status: m.Status,
		Reason: m.Reason,
		Description: m.Description,
		Resolution: m.Resolution,
		OpenedAt: m.OpenedAt,
		ResolvedAt: m.ResolvedAt,
		TransactionID: m.TransactionID,
		OpenedByID: m.OpenedByID,
		ResolvedByID: m.ResolvedByID,
	}
}
