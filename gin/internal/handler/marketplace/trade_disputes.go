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
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/disputes/{id}/escalate", h.Escalate)
	g.POST("/:id/api/disputes/{id}/resolve", h.Resolve)
	g.POST("/:id/api/disputes/{id}/review", h.Review)
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
	row.Reason = req.Reason
	row.Description = req.Description
	row.Status = req.Status
	row.Resolution = req.Resolution
	row.OpenedAt = req.OpenedAt
	row.ResolvedAt = req.ResolvedAt
	row.TransactionID = req.TransactionID
	row.OpenedByID = req.OpenedByID
	row.ResolvedByID = req.ResolvedByID
	if err := h.db.Create(&row).Error; err != nil {
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

func (h *TradeDisputeHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeDispute
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	var req model.TradeDisputeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTradeDispute(&row)
	if msgs := validateTradeDispute(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeDisputeHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TradeDisputeHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TradeDispute{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeDispute"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
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

func validateTradeDispute(req *model.TradeDisputeCreateRequest) []string {
	var errs []string
	if !((!( req.ResolvedAt != nil ) || (req.Status == model.TradeDisputeStatusType_Resolved))) {
		errs = append(errs, "resolved_at_requires_terminal_status")
	}
	return errs
}

func toCreateRequestTradeDispute(m *model.TradeDispute) model.TradeDisputeCreateRequest {
	return model.TradeDisputeCreateRequest{
		Reason: m.Reason,
		Description: m.Description,
		Status: m.Status,
		Resolution: m.Resolution,
		OpenedAt: m.OpenedAt,
		ResolvedAt: m.ResolvedAt,
		TransactionID: m.TransactionID,
		OpenedByID: m.OpenedByID,
		ResolvedByID: m.ResolvedByID,
	}
}
