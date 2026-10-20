package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeTransactionHandler struct { db *gorm.DB }

func NewTradeTransactionHandler(db *gorm.DB) *TradeTransactionHandler {
	return &TradeTransactionHandler{db: db}
}

func (h *TradeTransactionHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/trade_transactions")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Post("/:id/api/transactions/{id}/complete", h.Complete)
	g.Post("/:id/api/transactions/{id}/refund", h.Refund)
	g.Post("/:id/api/transactions/{id}/dispute", h.OpenDispute)
	g.Get("/:id/api/transactions/{id}/seller-net", h.SellerNet)
}

func (h *TradeTransactionHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeTransaction
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TradeTransactionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TradeTransactionHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeTransaction") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeTransactionHandler) Complete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeTransaction") }
		return handler.DbError(c, err)
	}
	err := row.Complete()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeTransactionHandler) Refund(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeTransaction") }
		return handler.DbError(c, err)
	}
	err := row.Refund()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeTransactionHandler) OpenDispute(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeTransaction") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	reason := func() string {
		v, ok := body["reason"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.OpenDispute(reason)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeTransactionHandler) SellerNet(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeTransaction") }
		return handler.DbError(c, err)
	}
	result, err := row.SellerNet()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateTradeTransaction(req *model.TradeTransactionCreateRequest) []string {
	var errs []string
	if (req.Status == model.TradeTransactionStatusType_Completed) && req.CompletedAt == nil {
		errs = append(errs, "completed_at is required")
	}
	if !(float64(req.PlatformFee) <= float64(req.FinalPrice)) {
		errs = append(errs, "Platform fee cannot exceed the final price")
	}
	if !(float64(req.PlatformFee) >= 0) {
		errs = append(errs, "Platform fee must not be negative")
	}
	if !(float64(req.FinalPrice) > 0) {
		errs = append(errs, "Transaction final price must be greater than zero")
	}
	if !((!( req.Status == model.TradeTransactionStatusType_Completed ) || (req.CompletedAt != nil))) {
		errs = append(errs, "Completed transaction must have a completed_at timestamp")
	}
	return errs
}

func toCreateRequestTradeTransaction(m *model.TradeTransaction) model.TradeTransactionCreateRequest {
	return model.TradeTransactionCreateRequest{
		FinalPrice: m.FinalPrice,
		PlatformFee: m.PlatformFee,
		Status: m.Status,
		CompletedAt: m.CompletedAt,
		ListingID: m.ListingID,
		BuyerID: m.BuyerID,
		SellerID: m.SellerID,
	}
}
