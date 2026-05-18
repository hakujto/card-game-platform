package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardSetHandler struct { db *gorm.DB }

func NewCardSetHandler(db *gorm.DB) *CardSetHandler {
	return &CardSetHandler{db: db}
}

func (h *CardSetHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/card_sets")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *CardSetHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CardSet
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardSetResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardSetHandler) Create(c *gin.Context) {
	var req model.CardSetCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.CardSet{}
	row.Name = req.Name
	row.Code = req.Code
	row.ReleaseDate = req.ReleaseDate
	row.SetType = req.SetType
	row.TotalCards = req.TotalCards
	row.Description = req.Description
	row.LogoUrl = req.LogoUrl
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardSetHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardSetHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	var req model.CardSetUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardSetHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardSetHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CardSet{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
