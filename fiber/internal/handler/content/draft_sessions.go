package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftSessionHandler struct { db *gorm.DB }

func NewDraftSessionHandler(db *gorm.DB) *DraftSessionHandler {
	return &DraftSessionHandler{db: db}
}

func (h *DraftSessionHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/draft_sessions")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/start", h.Start)
	g.Post("/:id/abandon", h.Abandon)
	g.Post("/:id/complete", h.Complete)
	g.Get("/:id/full", h.IsFull)
	g.Patch("/:id/transitions/waitingforplayers-to-drafting", h.TransitionWaitingForPlayersToDrafting)
	g.Patch("/:id/transitions/drafting-to-completed", h.TransitionDraftingToCompleted)
	g.Patch("/:id/transitions/drafting-to-abandoned", h.TransitionDraftingToAbandoned)
	g.Patch("/:id/transitions/waitingforplayers-to-abandoned", h.TransitionWaitingForPlayersToAbandoned)
	g.Patch("/:id/transitions/completed-to-drafting", h.TransitionCompletedToDrafting)
	g.Patch("/:id/transitions/abandoned-to-drafting", h.TransitionAbandonedToDrafting)
}

func (h *DraftSessionHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftSession
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DraftSessionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DraftSessionHandler) Create(c *fiber.Ctx) error {
	var req model.DraftSessionCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateDraftSession(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.DraftSession{}
	row.Status = req.Status
	row.DraftType = req.DraftType
	row.PackContents = req.PackContents
	row.Seats = req.Seats
	row.TimePerPickSeconds = req.TimePerPickSeconds
	row.CompletedAt = req.CompletedAt
	row.CardSetID = req.CardSetID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DraftSessionHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DraftSessionHandler) Start(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	err := row.Start()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DraftSessionHandler) Abandon(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	err := row.Abandon()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DraftSessionHandler) Complete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	err := row.Complete()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DraftSessionHandler) IsFull(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	result, err := row.IsFull()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *DraftSessionHandler) TransitionWaitingForPlayersToDrafting(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Drafting"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.DraftSessionStatusType_Drafting
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Start() // @after
	return c.JSON(row.ToResponse())
}

func (h *DraftSessionHandler) TransitionDraftingToCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Completed"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.DraftSessionStatusType_Completed
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Complete() // @after
	return c.JSON(row.ToResponse())
}

func (h *DraftSessionHandler) TransitionDraftingToAbandoned(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionDraftingToAbandoned := []string{"Admin", "Organizer"}
	roleOkTransitionDraftingToAbandoned := false
	for _, r := range allowedRolesTransitionDraftingToAbandoned { if r == userRole { roleOkTransitionDraftingToAbandoned = true; break } }
	if !roleOkTransitionDraftingToAbandoned { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Drafting -> Abandoned"}) }
	if err := row.AssertTransition("Abandoned"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.DraftSessionStatusType_Abandoned
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Abandon() // @after
	return c.JSON(row.ToResponse())
}

func (h *DraftSessionHandler) TransitionWaitingForPlayersToAbandoned(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionWaitingForPlayersToAbandoned := []string{"Admin", "Organizer"}
	roleOkTransitionWaitingForPlayersToAbandoned := false
	for _, r := range allowedRolesTransitionWaitingForPlayersToAbandoned { if r == userRole { roleOkTransitionWaitingForPlayersToAbandoned = true; break } }
	if !roleOkTransitionWaitingForPlayersToAbandoned { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition WaitingForPlayers -> Abandoned"}) }
	if err := row.AssertTransition("Abandoned"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.DraftSessionStatusType_Abandoned
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Abandon() // @after
	return c.JSON(row.ToResponse())
}

func (h *DraftSessionHandler) TransitionCompletedToDrafting(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Completed -> Drafting is not allowed")
}

func (h *DraftSessionHandler) TransitionAbandonedToDrafting(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftSession") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Abandoned -> Drafting is not allowed")
}

// ── Validation rules ─────────────────────────────────────────────
func validateDraftSession(req *model.DraftSessionCreateRequest) []string {
	var errs []string
	if !((req.Seats >= 2 && req.Seats <= 16)) {
		errs = append(errs, "Draft session must have between 2 and 16 seats")
	}
	if !((!( req.CompletedAt != nil ) || (req.Status == model.DraftSessionStatusType_Completed))) {
		errs = append(errs, "completed_at can only be set when draft status is Completed")
	}
	if !(req.TimePerPickSeconds > 0) {
		errs = append(errs, "Time per pick must be greater than zero")
	}
	return errs
}

func toCreateRequestDraftSession(m *model.DraftSession) model.DraftSessionCreateRequest {
	return model.DraftSessionCreateRequest{
		Status: m.Status,
		DraftType: m.DraftType,
		PackContents: m.PackContents,
		Seats: m.Seats,
		TimePerPickSeconds: m.TimePerPickSeconds,
		CompletedAt: m.CompletedAt,
		CardSetID: m.CardSetID,
	}
}
