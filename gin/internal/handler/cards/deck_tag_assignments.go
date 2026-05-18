package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckTagAssignmentHandler struct { db *gorm.DB }

func NewDeckTagAssignmentHandler(db *gorm.DB) *DeckTagAssignmentHandler {
	return &DeckTagAssignmentHandler{db: db}
}

func (h *DeckTagAssignmentHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/deck_tag_assignments")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *DeckTagAssignmentHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckTagAssignment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DeckTagAssignmentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DeckTagAssignmentHandler) Create(c *gin.Context) {
	var req model.DeckTagAssignmentCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.DeckTagAssignment{}
	row.DeckID = req.DeckID
	row.TagID = req.TagID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DeckTagAssignmentHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTagAssignment"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckTagAssignmentHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTagAssignment"); return }
		handler.DbError(c, err); return
	}
	var req model.DeckTagAssignmentUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckTagAssignmentHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DeckTagAssignmentHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DeckTagAssignment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckTagAssignment"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
