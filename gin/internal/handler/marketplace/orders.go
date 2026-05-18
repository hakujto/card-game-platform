package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type OrderHandler struct { db *gorm.DB }

func NewOrderHandler(db *gorm.DB) *OrderHandler {
	return &OrderHandler{db: db}
}

func (h *OrderHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/orders")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.DELETE("/:id/cancel", h.Cancel)
	g.POST("/:id/pay", h.Pay)
	g.GET("/:id/total", h.CalculateTotal)
	g.PATCH("/:id/discount", h.ApplyDiscount)
	g.POST("/:id/refund", h.Refund)
}

func (h *OrderHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Order
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.OrderResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *OrderHandler) Create(c *gin.Context) {
	var req model.OrderCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateOrder(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
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
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *OrderHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *OrderHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	var req model.OrderUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestOrder(&row)
	if msgs := validateOrder(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *OrderHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *OrderHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Order{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *OrderHandler) Cancel(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	err := row.Cancel()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *OrderHandler) Pay(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	paymentRef := func() string {
		v, ok := body["payment_ref"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.Pay(paymentRef)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *OrderHandler) CalculateTotal(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	result, err := row.CalculateTotal()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *OrderHandler) ApplyDiscount(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	percent := func() int {
		v, ok := body["percent"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.ApplyDiscount(percent)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *OrderHandler) Refund(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	err := row.Refund()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *OrderHandler) SetStatus(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var body struct{ Value string `json:"value"` }
	if err := c.ShouldBindJSON(&body); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	var row model.Order
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Order"); return }
		handler.DbError(c, err); return
	}
	row.Status = model.OrderStatusType(body.Value)
	if row.Status == "Shipped" {
		_ = row.NotifyShipped() // @on(status = Shipped)
	}
	h.db.Save(&row)
	c.JSON(http.StatusOK, row.ToResponse())
}

func validateOrder(req *model.OrderCreateRequest) []string {
	var errs []string
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
