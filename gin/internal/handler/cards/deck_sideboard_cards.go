package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckSideboardCardHandler struct { db *gorm.DB }

func NewDeckSideboardCardHandler(db *gorm.DB) *DeckSideboardCardHandler {
	return &DeckSideboardCardHandler{db: db}
}

func (h *DeckSideboardCardHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/deck_sideboard_cards")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *DeckSideboardCardHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckSideboardCard
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DeckSideboardCardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DeckSideboardCardHandler) Create(c *gin.Context) {
	var req model.DeckSideboardCardCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.DeckSideboardCard{}
	row.Quantity = req.Quantity
	row.DeckID = req.DeckID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DeckSideboardCardHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckSideboardCard"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckSideboardCardHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckSideboardCard"); return }
		handler.DbError(c, err); return
	}
	var req model.DeckSideboardCardUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckSideboardCardHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DeckSideboardCardHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DeckSideboardCard{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckSideboardCard"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
