package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftParticipantHandler struct { db *gorm.DB }

func NewDraftParticipantHandler(db *gorm.DB) *DraftParticipantHandler {
	return &DraftParticipantHandler{db: db}
}

func (h *DraftParticipantHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/draft_participants")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/draft-participants/{id}/pick", h.PickCard)
}

func (h *DraftParticipantHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftParticipant
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DraftParticipantResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DraftParticipantHandler) Create(c *gin.Context) {
	var req model.DraftParticipantCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.DraftParticipant{}
	row.SeatNumber = req.SeatNumber
	row.JoinedAt = req.JoinedAt
	row.SessionID = req.SessionID
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DraftParticipantHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftParticipant"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftParticipantHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftParticipant"); return }
		handler.DbError(c, err); return
	}
	var req model.DraftParticipantUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftParticipantHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DraftParticipantHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DraftParticipant{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftParticipant"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *DraftParticipantHandler) PickCard(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftParticipant"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	cardId := func() int {
		v, ok := body["card_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	packNumber := func() int {
		v, ok := body["pack_number"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.PickCard(cardId, packNumber)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
