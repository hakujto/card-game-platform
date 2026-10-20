package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type ProductHandler struct { db *gorm.DB }

func NewProductHandler(db *gorm.DB) *ProductHandler {
	return &ProductHandler{db: db}
}

func (h *ProductHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/products")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/activate", h.Activate)
	g.Post("/:id/deactivate", h.Deactivate)
	g.Patch("/:id/discount", h.ApplyDiscount)
	g.Post("/:id/restock", h.Restock)
	g.Get("/:id/effective-price", h.EffectivePrice)
	g.Get("/:id/in-stock", h.IsInStock)
}

func (h *ProductHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Product
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("description LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.ProductResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *ProductHandler) Create(c *fiber.Ctx) error {
	var req model.ProductCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateProduct(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Product{}
	row.Name = req.Name
	row.ProductType = req.ProductType
	row.Price = req.Price
	row.Stock = req.Stock
	row.Active = req.Active
	row.DiscountPercent = req.DiscountPercent
	row.Description = req.Description
	row.ImageUrl = req.ImageUrl
	row.Featured = req.Featured
	row.CardID = req.CardID
	row.CardSetID = req.CardSetID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *ProductHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ProductHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	var req model.ProductUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestProduct(&row)
	if msgs := validateProduct(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ProductHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *ProductHandler) Activate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	err := row.Activate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ProductHandler) Deactivate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	err := row.Deactivate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ProductHandler) ApplyDiscount(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	percent := func() int {
		v, ok := body["percent"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.ApplyDiscount(percent)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *ProductHandler) Restock(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Restock(quantity)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ProductHandler) EffectivePrice(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	result, err := row.EffectivePrice()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *ProductHandler) IsInStock(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Product") }
		return handler.DbError(c, err)
	}
	result, err := row.IsInStock()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateProduct(req *model.ProductCreateRequest) []string {
	var errs []string
	if !(float64(req.Price) > 0) {
		errs = append(errs, "Product price must be greater than zero")
	}
	if !(req.Stock >= 0) {
		errs = append(errs, "Product stock must not be negative")
	}
	if !((req.DiscountPercent >= 0 && req.DiscountPercent <= 100)) {
		errs = append(errs, "Product discount percent must be between 0 and 100")
	}
	return errs
}

func toCreateRequestProduct(m *model.Product) model.ProductCreateRequest {
	return model.ProductCreateRequest{
		Name: m.Name,
		ProductType: m.ProductType,
		Price: m.Price,
		Stock: m.Stock,
		Active: m.Active,
		DiscountPercent: m.DiscountPercent,
		Description: m.Description,
		ImageUrl: m.ImageUrl,
		Featured: m.Featured,
		CardID: m.CardID,
		CardSetID: m.CardSetID,
	}
}
