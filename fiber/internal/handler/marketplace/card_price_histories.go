package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type CardPriceHistoryHandler struct { db *gorm.DB }

func NewCardPriceHistoryHandler(db *gorm.DB) *CardPriceHistoryHandler {
	return &CardPriceHistoryHandler{db: db}
}

func (h *CardPriceHistoryHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/card_price_histories")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Get("/:id/api/price-history/{id}/change", h.PriceChangePercent)
	g.Get("/:id/api/price-history/{id}/spike", h.IsPriceSpike)
}

func (h *CardPriceHistoryHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CardPriceHistory
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CardPriceHistoryResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CardPriceHistoryHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardPriceHistory
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardPriceHistory") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardPriceHistoryHandler) PriceChangePercent(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardPriceHistory
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardPriceHistory") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	previousAvg := func() float64 {
		v, ok := body["previous_avg"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return f
	}()
	result, err := row.PriceChangePercent(previousAvg)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardPriceHistoryHandler) IsPriceSpike(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardPriceHistory
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardPriceHistory") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	thresholdPercent := func() int {
		v, ok := body["threshold_percent"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.IsPriceSpike(thresholdPercent)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateCardPriceHistory(req *model.CardPriceHistoryCreateRequest) []string {
	var errs []string
	if !((float64(req.MinPrice) <= float64(req.AvgPrice) && float64(req.AvgPrice) <= float64(req.MaxPrice))) {
		errs = append(errs, "min_price <= avg_price <= max_price must hold")
	}
	if !(req.Volume >= 0) {
		errs = append(errs, "Price history volume must not be negative")
	}
	if !(float64(req.MinPrice) >= 0) {
		errs = append(errs, "Prices must not be negative")
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
