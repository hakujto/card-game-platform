package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type CardPriceHistoryHandler struct { db *gorm.DB }

func NewCardPriceHistoryHandler(db *gorm.DB) *CardPriceHistoryHandler {
	return &CardPriceHistoryHandler{db: db}
}

func (h *CardPriceHistoryHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/card_price_histories")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *CardPriceHistoryHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CardPriceHistory
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardPriceHistoryResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardPriceHistoryHandler) Create(c *gin.Context) {
	var req model.CardPriceHistoryCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCardPriceHistory(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.CardPriceHistory{}
	row.PriceDate = req.PriceDate
	row.AvgPrice = req.AvgPrice
	row.MinPrice = req.MinPrice
	row.MaxPrice = req.MaxPrice
	row.Volume = req.Volume
	row.Foil = req.Foil
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardPriceHistoryHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardPriceHistory
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardPriceHistory"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardPriceHistoryHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardPriceHistory
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardPriceHistory"); return }
		handler.DbError(c, err); return
	}
	var req model.CardPriceHistoryUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCardPriceHistory(&row)
	if msgs := validateCardPriceHistory(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardPriceHistoryHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardPriceHistoryHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CardPriceHistory{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardPriceHistory"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func validateCardPriceHistory(req *model.CardPriceHistoryCreateRequest) []string {
	var errs []string
	if !((float64(req.MinPrice) <= float64(req.AvgPrice) && float64(req.AvgPrice) <= float64(req.MaxPrice))) {
		errs = append(errs, "min_price <= avg_price <= max_price must hold")
	}
	return errs
}

func toCreateRequestCardPriceHistory(m *model.CardPriceHistory) model.CardPriceHistoryCreateRequest {
	return model.CardPriceHistoryCreateRequest{
		PriceDate: m.PriceDate,
		AvgPrice: m.AvgPrice,
		MinPrice: m.MinPrice,
		MaxPrice: m.MaxPrice,
		Volume: m.Volume,
		Foil: m.Foil,
		CardID: m.CardID,
	}
}
