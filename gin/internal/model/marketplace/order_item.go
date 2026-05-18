package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

// OrderItemCreateRequest is the POST body.
type OrderItemCreateRequest struct {
	Quantity int `json:"quantity"`
	PriceAtPurchase types.Decimal `json:"price_at_purchase"`
	Foil bool `json:"foil"`
	OrderID uint `json:"order_id"`
	ProductID uint `json:"product_id"`
}

// OrderItemUpdateRequest is the PUT/PATCH body — all fields optional.
type OrderItemUpdateRequest struct {
	Quantity *int `json:"quantity"`
	PriceAtPurchase *types.Decimal `json:"price_at_purchase"`
	Foil *bool `json:"foil"`
	OrderID *uint `json:"order_id"`
	ProductID *uint `json:"product_id"`
}

// OrderItemResponse is the JSON representation returned by the API.
type OrderItemResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Quantity int `json:"quantity"`
	PriceAtPurchase types.Decimal `json:"price_at_purchase"`
	Foil bool `json:"foil"`
	OrderID uint `json:"order_id"`
	ProductID uint `json:"product_id"`
}

type OrderItem struct {
	gorm.Model
	Quantity int `gorm:"column:quantity;not null"`
	PriceAtPurchase types.Decimal `gorm:"column:price_at_purchase;type:decimal(10,2);not null"`
	Foil bool `gorm:"column:foil;default:false"`
	OrderID uint `gorm:"column:order_id"`
	ProductID uint `gorm:"column:product_id"`
}

func (m *OrderItem) ToResponse() OrderItemResponse {
	return OrderItemResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Quantity: m.Quantity,
		PriceAtPurchase: m.PriceAtPurchase,
		Foil: m.Foil,
		OrderID: m.OrderID,
		ProductID: m.ProductID,
	}
}

func (m *OrderItem) ApplyUpdate(req OrderItemUpdateRequest) {
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.PriceAtPurchase != nil { m.PriceAtPurchase = *req.PriceAtPurchase }
	if req.Foil != nil { m.Foil = *req.Foil }
	if req.OrderID != nil { m.OrderID = *req.OrderID }
	if req.ProductID != nil { m.ProductID = *req.ProductID }
}

func (m *OrderItem) LineTotal()  (float64, error) {
	return 0.0, fmt.Errorf("LineTotal: not implemented")
}
