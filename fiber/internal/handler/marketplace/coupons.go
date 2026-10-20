package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type CouponHandler struct { db *gorm.DB }

func NewCouponHandler(db *gorm.DB) *CouponHandler {
	return &CouponHandler{db: db}
}

func (h *CouponHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/coupons")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Get("/:id/valid", h.IsValid)
	g.Get("/:id/applicable", h.IsApplicableToOrder)
	g.Post("/:id/redeem", h.Redeem)
	g.Post("/:id/deactivate", h.Deactivate)
}

func (h *CouponHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Coupon
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("code LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CouponResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CouponHandler) Create(c *fiber.Ctx) error {
	var req model.CouponCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateCoupon(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Coupon{}
	row.Code = req.Code
	row.DiscountType = req.DiscountType
	row.DiscountValue = req.DiscountValue
	row.MinOrderValue = req.MinOrderValue
	row.MaxUses = req.MaxUses
	row.UsesCount = req.UsesCount
	row.ValidFrom = req.ValidFrom
	row.ValidUntil = req.ValidUntil
	row.IsActive = req.IsActive
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CouponHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CouponHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	var req model.CouponUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCoupon(&row)
	if msgs := validateCoupon(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CouponHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *CouponHandler) IsValid(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	result, err := row.IsValid()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CouponHandler) IsApplicableToOrder(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	orderTotal := func() float64 {
		v, ok := body["order_total"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return f
	}()
	result, err := row.IsApplicableToOrder(orderTotal)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CouponHandler) Redeem(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	if !(row.IsActive) {
		return handler.UnprocessableError(c, "Guard condition not met for redeem")
	}
	err := row.Redeem()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CouponHandler) Deactivate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Coupon") }
		return handler.DbError(c, err)
	}
	err := row.Deactivate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateCoupon(req *model.CouponCreateRequest) []string {
	var errs []string
	if !(req.ValidUntil > req.ValidFrom) {
		errs = append(errs, "Coupon expiry must be after its start date")
	}
	if !(float64(req.DiscountValue) > 0) {
		errs = append(errs, "Discount value must be greater than zero")
	}
	if !((!( req.DiscountType == model.CouponDiscountTypeType_Percent ) || ((float64(req.DiscountValue) >= 1 && float64(req.DiscountValue) <= 100)))) {
		errs = append(errs, "Percent discount must be between 1 and 100")
	}
	if !((!( req.MaxUses != nil ) || ((req.MaxUses != nil && req.UsesCount <= *req.MaxUses)))) {
		errs = append(errs, "Coupon uses count cannot exceed max_uses")
	}
	return errs
}

func toCreateRequestCoupon(m *model.Coupon) model.CouponCreateRequest {
	return model.CouponCreateRequest{
		Code: m.Code,
		DiscountType: m.DiscountType,
		DiscountValue: m.DiscountValue,
		MinOrderValue: m.MinOrderValue,
		MaxUses: m.MaxUses,
		UsesCount: m.UsesCount,
		ValidFrom: m.ValidFrom,
		ValidUntil: m.ValidUntil,
		IsActive: m.IsActive,
	}
}
