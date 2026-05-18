package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftSessionHandler struct { db *gorm.DB }

func NewDraftSessionHandler(db *gorm.DB) *DraftSessionHandler {
	return &DraftSessionHandler{db: db}
}

func (h *DraftSessionHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/draft_sessions")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/draft-sessions/{id}/start", h.Start)
	g.POST("/:id/api/draft-sessions/{id}/abandon", h.Abandon)
	g.POST("/:id/api/draft-sessions/{id}/complete", h.Complete)
	g.GET("/:id/api/draft-sessions/{id}/full", h.IsFull)
}

func (h *DraftSessionHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftSession
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DraftSessionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DraftSessionHandler) Create(c *gin.Context) {
	var req model.DraftSessionCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateDraftSession(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.DraftSession{}
	row.Status = req.Status
	row.DraftType = req.DraftType
	row.Seats = req.Seats
	row.CompletedAt = req.CompletedAt
	row.CardSetID = req.CardSetID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DraftSessionHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftSessionHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	var req model.DraftSessionUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestDraftSession(&row)
	if msgs := validateDraftSession(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftSessionHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DraftSessionHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DraftSession{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *DraftSessionHandler) Start(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	err := row.Start()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DraftSessionHandler) Abandon(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	err := row.Abandon()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DraftSessionHandler) Complete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	err := row.Complete()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DraftSessionHandler) IsFull(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftSession
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftSession"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsFull()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateDraftSession(req *model.DraftSessionCreateRequest) []string {
	var errs []string
	if !((req.Seats >= 2 && req.Seats <= 16)) {
		errs = append(errs, "Draft session must have between 2 and 16 seats")
	}
	if !((!( req.CompletedAt != nil ) || (req.Status == model.DraftSessionStatusType_Completed))) {
		errs = append(errs, "completed_at can only be set when draft status is Completed")
	}
	return errs
}

func toCreateRequestDraftSession(m *model.DraftSession) model.DraftSessionCreateRequest {
	return model.DraftSessionCreateRequest{
		Status: m.Status,
		DraftType: m.DraftType,
		Seats: m.Seats,
		CompletedAt: m.CompletedAt,
		CardSetID: m.CardSetID,
	}
}
