package handler_marketplace

import (
	"regexp"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type OrderHandler struct { db *gorm.DB }

func NewOrderHandler(db *gorm.DB) *OrderHandler {
	return &OrderHandler{db: db}
}

func (h *OrderHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/orders")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id/cancel", h.Cancel)
	g.Post("/:id/pay", h.Pay)
	g.Post("/:id/process-payment", h.ProcessPayment)
	g.Get("/:id/total", h.CalculateTotal)
	g.Patch("/:id/discount", h.ApplyDiscount)
	g.Post("/:id/refund", h.Refund)
	g.Patch("/:id/transitions/pending-to-paid", h.TransitionPendingToPaid)
	g.Patch("/:id/transitions/paid-to-processing", h.TransitionPaidToProcessing)
	g.Patch("/:id/transitions/processing-to-shipped", h.TransitionProcessingToShipped)
	g.Patch("/:id/transitions/shipped-to-completed", h.TransitionShippedToCompleted)
	g.Patch("/:id/transitions/pending-to-cancelled", h.TransitionPendingToCancelled)
	g.Patch("/:id/transitions/paid-to-cancelled", h.TransitionPaidToCancelled)
	g.Patch("/:id/transitions/completed-to-refunded", h.TransitionCompletedToRefunded)
	g.Patch("/:id/transitions/refunded-to-completed", h.TransitionRefundedToCompleted)
	g.Patch("/:id/transitions/completed-to-cancelled", h.TransitionCompletedToCancelled)
}

func (h *OrderHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Order
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.OrderResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *OrderHandler) Create(c *fiber.Ctx) error {
	var req model.OrderCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateOrder(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Order{}
	row.Status = req.Status
	row.Total = req.Total
	row.DiscountApplied = req.DiscountApplied
	row.Currency = req.Currency
	row.PaymentMethod = req.PaymentMethod
	row.PaymentReference = req.PaymentReference
	row.ShippingAddress = req.ShippingAddress
	row.TrackingNumber = req.TrackingNumber
	row.PaidAt = req.PaidAt
	row.ShippedAt = req.ShippedAt
	row.PlayerID = req.PlayerID
	row.CouponID = req.CouponID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *OrderHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.PlayerID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) Cancel(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	err := row.Cancel()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *OrderHandler) Pay(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	if !(row.Status == model.OrderStatusType_Pending) {
		return handler.UnprocessableError(c, "Guard condition not met for pay")
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	paymentRef := func() string {
		v, ok := body["payment_ref"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.Pay(paymentRef)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *OrderHandler) ProcessPayment(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	result, err := row.ProcessPayment()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *OrderHandler) CalculateTotal(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	result, err := row.CalculateTotal()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *OrderHandler) ApplyDiscount(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
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

func (h *OrderHandler) Refund(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	err := row.Refund()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *OrderHandler) SetStatus(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var body struct{ Value string `json:"value"` }
	if err := c.BodyParser(&body); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	row.Status = model.OrderStatusType(body.Value)
	if row.Status == "Shipped" {
		_ = row.NotifyShipped() // @on(status = Shipped)
	}
	h.db.Save(&row)
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionPendingToPaid(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Paid"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.PaymentMethod == nil {
		return handler.UnprocessableError(c, "payment_method is required for this transition")
	}
	row.Status = model.OrderStatusType_Paid
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_, _ = row.ProcessPayment() // @after
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionPaidToProcessing(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPaidToProcessing := []string{"Admin", "Staff"}
	roleOkTransitionPaidToProcessing := false
	for _, r := range allowedRolesTransitionPaidToProcessing { if r == userRole { roleOkTransitionPaidToProcessing = true; break } }
	if !roleOkTransitionPaidToProcessing { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Paid -> Processing"}) }
	if err := row.AssertTransition("Processing"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.OrderStatusType_Processing
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionProcessingToShipped(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionProcessingToShipped := []string{"Admin", "Staff"}
	roleOkTransitionProcessingToShipped := false
	for _, r := range allowedRolesTransitionProcessingToShipped { if r == userRole { roleOkTransitionProcessingToShipped = true; break } }
	if !roleOkTransitionProcessingToShipped { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Processing -> Shipped"}) }
	if err := row.AssertTransition("Shipped"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.TrackingNumber == nil {
		return handler.UnprocessableError(c, "tracking_number is required for this transition")
	}
	row.Status = model.OrderStatusType_Shipped
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.NotifyShipped() // @after
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionShippedToCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionShippedToCompleted := []string{"Admin", "Staff"}
	roleOkTransitionShippedToCompleted := false
	for _, r := range allowedRolesTransitionShippedToCompleted { if r == userRole { roleOkTransitionShippedToCompleted = true; break } }
	if !roleOkTransitionShippedToCompleted { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Shipped -> Completed"}) }
	if err := row.AssertTransition("Completed"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.OrderStatusType_Completed
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionPendingToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Cancelled"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.OrderStatusType_Cancelled
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Cancel() // @after
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionPaidToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPaidToCancelled := []string{"Admin", "Staff"}
	roleOkTransitionPaidToCancelled := false
	for _, r := range allowedRolesTransitionPaidToCancelled { if r == userRole { roleOkTransitionPaidToCancelled = true; break } }
	if !roleOkTransitionPaidToCancelled { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Paid -> Cancelled"}) }
	if err := row.AssertTransition("Cancelled"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.OrderStatusType_Cancelled
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Cancel() // @after
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionCompletedToRefunded(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionCompletedToRefunded := []string{"Admin"}
	roleOkTransitionCompletedToRefunded := false
	for _, r := range allowedRolesTransitionCompletedToRefunded { if r == userRole { roleOkTransitionCompletedToRefunded = true; break } }
	if !roleOkTransitionCompletedToRefunded { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Completed -> Refunded"}) }
	if err := row.AssertTransition("Refunded"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.OrderStatusType_Refunded
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Refund() // @after
	return c.JSON(row.ToResponse())
}

func (h *OrderHandler) TransitionRefundedToCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Refunded -> Completed is not allowed")
}

func (h *OrderHandler) TransitionCompletedToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Order") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Completed -> Cancelled is not allowed")
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *OrderHandler) hookAssignCurrencyDefault(row *model.Order) {
	// TODO: implement assign_currency_default
}

func (h *OrderHandler) hookNotifyStatusChange(row *model.Order) {
	// TODO: implement notify_status_change
}

// ── Validation rules ─────────────────────────────────────────────
func validateOrder(req *model.OrderCreateRequest) []string {
	var errs []string
	if matched, _ := regexp.MatchString(`[A-Z]{3}`, req.Currency); !matched {
		errs = append(errs, "currency has invalid format")
	}
	if (req.Status == model.OrderStatusType_Shipped) && req.TrackingNumber == nil {
		errs = append(errs, "tracking_number is required")
	}
	if (req.Status == model.OrderStatusType_Paid) && req.PaidAt == nil {
		errs = append(errs, "paid_at is required")
	}
	if !((!( req.Status == model.OrderStatusType_Paid ) || (req.PaidAt != nil))) {
		errs = append(errs, "Paid order must have paid_at set")
	}
	if !((!( req.Status == model.OrderStatusType_Shipped ) || (req.TrackingNumber != nil))) {
		errs = append(errs, "Shipped order must have a tracking number")
	}
	if !((!( req.ShippedAt != nil ) || (req.Status == model.OrderStatusType_Shipped))) {
		errs = append(errs, "shipped_at_requires_shipped_status")
	}
	if !(float64(req.Total) >= 0) {
		errs = append(errs, "Order total must not be negative")
	}
	if !(float64(req.DiscountApplied) <= float64(req.Total)) {
		errs = append(errs, "Discount applied cannot exceed order total")
	}
	return errs
}

func toCreateRequestOrder(m *model.Order) model.OrderCreateRequest {
	return model.OrderCreateRequest{
		Status: m.Status,
		Total: m.Total,
		DiscountApplied: m.DiscountApplied,
		Currency: m.Currency,
		PaymentMethod: m.PaymentMethod,
		PaymentReference: m.PaymentReference,
		ShippingAddress: m.ShippingAddress,
		TrackingNumber: m.TrackingNumber,
		PaidAt: m.PaidAt,
		ShippedAt: m.ShippedAt,
		PlayerID: m.PlayerID,
		CouponID: m.CouponID,
	}
}
