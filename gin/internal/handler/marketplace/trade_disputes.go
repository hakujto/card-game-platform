package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeDisputeHandler struct { db *gorm.DB }

func NewTradeDisputeHandler(db *gorm.DB) *TradeDisputeHandler {
	return &TradeDisputeHandler{db: db}
}

func (h *TradeDisputeHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/trade_disputes")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.POST("/:id/api/disputes/{id}/escalate", h.Escalate)
	g.POST("/:id/api/disputes/{id}/resolve", h.Resolve)
	g.POST("/:id/api/disputes/{id}/close", h.CloseResolved)
	g.POST("/:id/api/disputes/{id}/review", h.Review)
	g.PATCH("/:id/transitions/open-to-underreview", h.TransitionOpenToUnderReview)
	g.PATCH("/:id/transitions/underreview-to-resolved", h.TransitionUnderReviewToResolved)
	g.PATCH("/:id/transitions/underreview-to-escalated", h.TransitionUnderReviewToEscalated)
	g.PATCH("/:id/transitions/escalated-to-resolved", h.TransitionEscalatedToResolved)
	g.PATCH("/:id/transitions/resolved-to-open", h.TransitionResolvedToOpen)
}

func (h *TradeDisputeHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeDispute
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TradeDisputeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TradeDisputeHandler) Create(c *gin.Context) {
	var req model.TradeDisputeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTradeDispute(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
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
		if handler.IsUniqueViolation(err) { handler.UnprocessableError(c, "Value must be unique"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TradeDisputeHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) Escalate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	err := row.Escalate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeDisputeHandler) Resolve(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	resolutionText := func() string {
		v, ok := body["resolution_text"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Resolve(resolutionText)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeDisputeHandler) CloseResolved(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	err := row.CloseResolved()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeDisputeHandler) Review(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	err := row.Review()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeDisputeHandler) TransitionOpenToUnderReview(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	userRole, _ := c.Get("user_role")
	allowedRolesTransitionOpenToUnderReview := []string{"Admin", "Moderator"}
	roleOkTransitionOpenToUnderReview := false
	for _, r := range allowedRolesTransitionOpenToUnderReview { if r == userRole { roleOkTransitionOpenToUnderReview = true; break } }
	if !roleOkTransitionOpenToUnderReview { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for transition Open -> UnderReview"}); return }
	if err := row.AssertTransition("UnderReview"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	row.Status = model.TradeDisputeStatusType_UnderReview
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.Review() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionUnderReviewToResolved(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	userRole, _ := c.Get("user_role")
	allowedRolesTransitionUnderReviewToResolved := []string{"Admin", "Moderator"}
	roleOkTransitionUnderReviewToResolved := false
	for _, r := range allowedRolesTransitionUnderReviewToResolved { if r == userRole { roleOkTransitionUnderReviewToResolved = true; break } }
	if !roleOkTransitionUnderReviewToResolved { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for transition UnderReview -> Resolved"}); return }
	if err := row.AssertTransition("Resolved"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	if row.Resolution == nil {
		handler.UnprocessableError(c, "resolution is required for this transition"); return
	}
	row.Status = model.TradeDisputeStatusType_Resolved
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.CloseResolved() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionUnderReviewToEscalated(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	userRole, _ := c.Get("user_role")
	allowedRolesTransitionUnderReviewToEscalated := []string{"Admin"}
	roleOkTransitionUnderReviewToEscalated := false
	for _, r := range allowedRolesTransitionUnderReviewToEscalated { if r == userRole { roleOkTransitionUnderReviewToEscalated = true; break } }
	if !roleOkTransitionUnderReviewToEscalated { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for transition UnderReview -> Escalated"}); return }
	if err := row.AssertTransition("Escalated"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	row.Status = model.TradeDisputeStatusType_Escalated
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.Escalate() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionEscalatedToResolved(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	userRole, _ := c.Get("user_role")
	allowedRolesTransitionEscalatedToResolved := []string{"Admin"}
	roleOkTransitionEscalatedToResolved := false
	for _, r := range allowedRolesTransitionEscalatedToResolved { if r == userRole { roleOkTransitionEscalatedToResolved = true; break } }
	if !roleOkTransitionEscalatedToResolved { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for transition Escalated -> Resolved"}); return }
	if err := row.AssertTransition("Resolved"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	if row.Resolution == nil {
		handler.UnprocessableError(c, "resolution is required for this transition"); return
	}
	row.Status = model.TradeDisputeStatusType_Resolved
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.CloseResolved() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) TransitionResolvedToOpen(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	handler.ConflictError(c, "transition Resolved -> Open is not allowed")
	return
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
