package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeBidHandler struct { db *gorm.DB }

func NewTradeBidHandler(db *gorm.DB) *TradeBidHandler {
	return &TradeBidHandler{db: db}
}

func (h *TradeBidHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/trade_bids")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Get("/:id/api/bids/{id}/outbid", h.OutbidBy)
	g.Delete("/:id/api/bids/{id}", h.Retract)
}

func (h *TradeBidHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeBid
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TradeBidResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TradeBidHandler) Create(c *fiber.Ctx) error {
	var req model.TradeBidCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTradeBid(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TradeBid{}
	row.Amount = req.Amount
	row.PlacedAt = req.PlacedAt
	row.IsWinning = req.IsWinning
	row.ListingID = req.ListingID
	row.BidderID = req.BidderID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TradeBidHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeBid") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeBidHandler) OutbidBy(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeBid") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	newAmount := func() float64 {
		v, ok := body["new_amount"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return f
	}()
	result, err := row.OutbidBy(newAmount)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *TradeBidHandler) Retract(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeBid") }
		return handler.DbError(c, err)
	}
	err := row.Retract()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateTradeBid(req *model.TradeBidCreateRequest) []string {
	var errs []string
	if !(float64(req.Amount) > 0) {
		errs = append(errs, "Bid amount must be greater than zero")
	}
	return errs
}

func toCreateRequestTradeBid(m *model.TradeBid) model.TradeBidCreateRequest {
	return model.TradeBidCreateRequest{
		Amount: m.Amount,
		PlacedAt: m.PlacedAt,
		IsWinning: m.IsWinning,
		ListingID: m.ListingID,
		BidderID: m.BidderID,
	}
}
