package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type OrderItemHandler struct { db *gorm.DB }

func NewOrderItemHandler(db *gorm.DB) *OrderItemHandler {
	return &OrderItemHandler{db: db}
}

func (h *OrderItemHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/order_items")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
	g.Get("/:id/total", h.LineTotal)
}

func (h *OrderItemHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.OrderItem
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.OrderItemResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *OrderItemHandler) Create(c *fiber.Ctx) error {
	var req model.OrderItemCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateOrderItem(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.OrderItem{}
	row.Quantity = req.Quantity
	row.PriceAtPurchase = req.PriceAtPurchase
	row.Foil = req.Foil
	row.OrderID = req.OrderID
	row.ProductID = req.ProductID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *OrderItemHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.OrderItem
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "OrderItem") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *OrderItemHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.OrderItem{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "OrderItem") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *OrderItemHandler) LineTotal(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.OrderItem
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "OrderItem") }
		return handler.DbError(c, err)
	}
	result, err := row.LineTotal()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateOrderItem(req *model.OrderItemCreateRequest) []string {
	var errs []string
	if !(req.Quantity > 0) {
		errs = append(errs, "Order item quantity must be greater than zero")
	}
	if !(float64(req.PriceAtPurchase) >= 0) {
		errs = append(errs, "Price at purchase must not be negative")
	}
	return errs
}

func toCreateRequestOrderItem(m *model.OrderItem) model.OrderItemCreateRequest {
	return model.OrderItemCreateRequest{
		Quantity: m.Quantity,
		PriceAtPurchase: m.PriceAtPurchase,
		Foil: m.Foil,
		OrderID: m.OrderID,
		ProductID: m.ProductID,
	}
}
