package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type OrderStatusType string
const (
	OrderStatusType_Pending OrderStatusType = "Pending"
	OrderStatusType_Paid OrderStatusType = "Paid"
	OrderStatusType_Processing OrderStatusType = "Processing"
	OrderStatusType_Shipped OrderStatusType = "Shipped"
	OrderStatusType_Completed OrderStatusType = "Completed"
	OrderStatusType_Cancelled OrderStatusType = "Cancelled"
	OrderStatusType_Refunded OrderStatusType = "Refunded"
)

type OrderPaymentMethodType string
const (
	OrderPaymentMethodType_Card OrderPaymentMethodType = "Card"
	OrderPaymentMethodType_PayPal OrderPaymentMethodType = "PayPal"
	OrderPaymentMethodType_Crypto OrderPaymentMethodType = "Crypto"
	OrderPaymentMethodType_PlatformCredits OrderPaymentMethodType = "PlatformCredits"
)

// OrderCreateRequest is the POST body.
type OrderCreateRequest struct {
	Status OrderStatusType `json:"status" binding:"required"`
	Total types.Decimal `json:"total"`
	DiscountApplied types.Decimal `json:"discount_applied"`
	Currency string `json:"currency" binding:"required"`
	PaymentMethod *OrderPaymentMethodType `json:"payment_method"`
	PaymentReference *string `json:"payment_reference"`
	ShippingAddress *string `json:"shipping_address"`
	TrackingNumber *string `json:"tracking_number"`
	PaidAt *string `json:"paid_at"`
	ShippedAt *string `json:"shipped_at"`
	PlayerID uint `json:"player_id"`
	CouponID *uint `json:"coupon_id"`
}

// OrderUpdateRequest is the PUT/PATCH body — all fields optional.
type OrderUpdateRequest struct {
	Status *OrderStatusType `json:"status"`
	Total *types.Decimal `json:"total"`
	DiscountApplied *types.Decimal `json:"discount_applied"`
	Currency *string `json:"currency"`
	PaymentMethod *OrderPaymentMethodType `json:"payment_method"`
	PaymentReference *string `json:"payment_reference"`
	ShippingAddress *string `json:"shipping_address"`
	TrackingNumber *string `json:"tracking_number"`
	PaidAt *string `json:"paid_at"`
	ShippedAt *string `json:"shipped_at"`
	PlayerID *uint `json:"player_id"`
	CouponID *uint `json:"coupon_id"`
}

// OrderResponse is the JSON representation returned by the API.
type OrderResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Status OrderStatusType `json:"status"`
	Total types.Decimal `json:"total"`
	DiscountApplied types.Decimal `json:"discount_applied"`
	Currency string `json:"currency"`
	PaymentMethod *OrderPaymentMethodType `json:"payment_method"`
	PaymentReference *string `json:"payment_reference"`
	ShippingAddress *string `json:"shipping_address"`
	TrackingNumber *string `json:"tracking_number"`
	PaidAt *string `json:"paid_at"`
	ShippedAt *string `json:"shipped_at"`
	PlayerID uint `json:"player_id"`
	CouponID *uint `json:"coupon_id"`
}

type Order struct {
	gorm.Model
	Status OrderStatusType `gorm:"column:status;not null;default:'Pending'"`
	Total types.Decimal `gorm:"column:total;type:decimal(10,2);not null;default:0"`
	DiscountApplied types.Decimal `gorm:"column:discount_applied;type:decimal(10,2);not null;default:0"`
	Currency string `gorm:"column:currency;not null;default:'USD'"`
	PaymentMethod *OrderPaymentMethodType `gorm:"column:payment_method"`
	PaymentReference *string `gorm:"column:payment_reference"`
	ShippingAddress *string `gorm:"column:shipping_address;type:text"`
	TrackingNumber *string `gorm:"column:tracking_number"`
	PaidAt *string `gorm:"column:paid_at"`
	ShippedAt *string `gorm:"column:shipped_at"`
	PlayerID uint `gorm:"column:player_id"`
	CouponID *uint `gorm:"column:coupon_id"`
}

func (m *Order) ToResponse() OrderResponse {
	return OrderResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
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

func (m *Order) ApplyUpdate(req OrderUpdateRequest) {
	if req.Status != nil { m.Status = *req.Status }
	if req.Total != nil { m.Total = *req.Total }
	if req.DiscountApplied != nil { m.DiscountApplied = *req.DiscountApplied }
	if req.Currency != nil { m.Currency = *req.Currency }
	if req.PaymentMethod != nil { m.PaymentMethod = req.PaymentMethod }
	if req.PaymentReference != nil { m.PaymentReference = req.PaymentReference }
	if req.ShippingAddress != nil { m.ShippingAddress = req.ShippingAddress }
	if req.TrackingNumber != nil { m.TrackingNumber = req.TrackingNumber }
	if req.PaidAt != nil { m.PaidAt = req.PaidAt }
	if req.ShippedAt != nil { m.ShippedAt = req.ShippedAt }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
	if req.CouponID != nil { m.CouponID = req.CouponID }
}

func (m *Order) Cancel()  error {
	return fmt.Errorf("Cancel: not implemented")
}

func (m *Order) Pay(paymentRef string)  (bool, error) {
	return false, fmt.Errorf("Pay: not implemented")
}

func (m *Order) CalculateTotal()  (float64, error) {
	return 0.0, fmt.Errorf("CalculateTotal: not implemented")
}

func (m *Order) ApplyDiscount(percent int)  (float64, error) {
	return 0.0, fmt.Errorf("ApplyDiscount: not implemented")
}

func (m *Order) Refund()  error {
	return fmt.Errorf("Refund: not implemented")
}

func (m *Order) NotifyShipped()  error {
	return fmt.Errorf("NotifyShipped: not implemented")
}
