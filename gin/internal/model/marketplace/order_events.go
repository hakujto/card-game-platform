package model_marketplace

import (
	"cards_project/internal/types"
)

// Domain events emitted by Order.
type OrderOrderPaidEvent struct {
	OrderId int `json:"order_id"`
	PlayerId int `json:"player_id"`
	Total types.Decimal `json:"total"`
	PaymentMethod string `json:"payment_method"`
	PaidAt string `json:"paid_at"`
}

type OrderOrderShippedEvent struct {
	OrderId int `json:"order_id"`
	TrackingNumber string `json:"tracking_number"`
	ShippedAt string `json:"shipped_at"`
}

type OrderOrderRefundedEvent struct {
	OrderId int `json:"order_id"`
	RefundedAt string `json:"refunded_at"`
}
