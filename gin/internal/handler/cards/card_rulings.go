package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardRulingHandler struct { db *gorm.DB }

func NewCardRulingHandler(db *gorm.DB) *CardRulingHandler {
	return &CardRulingHandler{db: db}
}

func (h *CardRulingHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/card_rulings")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/card-rulings/{id}/current", h.IsCurrent)
	g.GET("/:id/api/card-rulings/{id}/supersedes", h.SupersedesPrevious)
}

func (h *CardRulingHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CardRuling
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardRulingResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardRulingHandler) Create(c *gin.Context) {
	var req model.CardRulingCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.CardRuling{}
	row.RulingText = req.RulingText
	row.PublishedAt = req.PublishedAt
	row.Source = req.Source
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardRulingHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardRuling"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardRulingHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardRuling"); return }
		handler.DbError(c, err); return
	}
	var req model.CardRulingUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardRulingHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardRulingHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CardRuling{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardRuling"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CardRulingHandler) IsCurrent(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardRuling"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsCurrent()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CardRulingHandler) SupersedesPrevious(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardRuling"); return }
		handler.DbError(c, err); return
	}
	result, err := row.SupersedesPrevious()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}
