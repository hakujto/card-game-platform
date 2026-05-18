package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftPickHandler struct { db *gorm.DB }

func NewDraftPickHandler(db *gorm.DB) *DraftPickHandler {
	return &DraftPickHandler{db: db}
}

func (h *DraftPickHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/draft_picks")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *DraftPickHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftPick
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DraftPickResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DraftPickHandler) Create(c *gin.Context) {
	var req model.DraftPickCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.DraftPick{}
	row.PickNumber = req.PickNumber
	row.PackNumber = req.PackNumber
	row.PickedAt = req.PickedAt
	row.ParticipantID = req.ParticipantID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DraftPickHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftPick"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftPickHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftPick"); return }
		handler.DbError(c, err); return
	}
	var req model.DraftPickUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftPickHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DraftPickHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DraftPick{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftPick"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
