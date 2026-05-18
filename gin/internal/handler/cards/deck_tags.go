package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckTagHandler struct { db *gorm.DB }

func NewDeckTagHandler(db *gorm.DB) *DeckTagHandler {
	return &DeckTagHandler{db: db}
}

func (h *DeckTagHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/deck_tags")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.PATCH("/:id/api/deck-tags/{id}/rename", h.Rename)
	g.POST("/:id/api/deck-tags/{id}/merge", h.MergeInto)
}

func (h *DeckTagHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckTag
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DeckTagResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DeckTagHandler) Create(c *gin.Context) {
	var req model.DeckTagCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.DeckTag{}
	row.Name = req.Name
	row.Color = req.Color
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DeckTagHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTag"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckTagHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTag"); return }
		handler.DbError(c, err); return
	}
	var req model.DeckTagUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckTagHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DeckTagHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DeckTag{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTag"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *DeckTagHandler) Rename(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTag"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	newName := func() string {
		v, ok := body["new_name"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Rename(newName)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DeckTagHandler) MergeInto(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTag"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	targetTagId := func() int {
		v, ok := body["target_tag_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.MergeInto(targetTagId)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
