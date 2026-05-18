package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type CouponDiscountTypeType string
const (
	CouponDiscountTypeType_Percent CouponDiscountTypeType = "Percent"
	CouponDiscountTypeType_Fixed CouponDiscountTypeType = "Fixed"
)

// CouponCreateRequest is the POST body.
type CouponCreateRequest struct {
	Code string `json:"code" binding:"required"`
	DiscountType CouponDiscountTypeType `json:"discount_type" binding:"required"`
	DiscountValue types.Decimal `json:"discount_value"`
	MinOrderValue types.Decimal `json:"min_order_value"`
	MaxUses *int `json:"max_uses"`
	UsesCount int `json:"uses_count"`
	ValidFrom string `json:"valid_from" binding:"required"`
	ValidUntil string `json:"valid_until" binding:"required"`
	IsActive bool `json:"is_active"`
}

// CouponUpdateRequest is the PUT/PATCH body — all fields optional.
type CouponUpdateRequest struct {
	Code *string `json:"code"`
	DiscountType *CouponDiscountTypeType `json:"discount_type"`
	DiscountValue *types.Decimal `json:"discount_value"`
	MinOrderValue *types.Decimal `json:"min_order_value"`
	MaxUses *int `json:"max_uses"`
	UsesCount *int `json:"uses_count"`
	ValidFrom *string `json:"valid_from"`
	ValidUntil *string `json:"valid_until"`
	IsActive *bool `json:"is_active"`
}

// CouponResponse is the JSON representation returned by the API.
type CouponResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Code string `json:"code"`
	DiscountType CouponDiscountTypeType `json:"discount_type"`
	DiscountValue types.Decimal `json:"discount_value"`
	MinOrderValue types.Decimal `json:"min_order_value"`
	MaxUses *int `json:"max_uses"`
	UsesCount int `json:"uses_count"`
	ValidFrom string `json:"valid_from"`
	ValidUntil string `json:"valid_until"`
	IsActive bool `json:"is_active"`
}

type Coupon struct {
	gorm.Model
	Code string `gorm:"column:code;not null"`
	DiscountType CouponDiscountTypeType `gorm:"column:discount_type;not null;default:'Percent'"`
	DiscountValue types.Decimal `gorm:"column:discount_value;type:decimal(10,2);not null"`
	MinOrderValue types.Decimal `gorm:"column:min_order_value;type:decimal(10,2);not null;default:0"`
	MaxUses *int `gorm:"column:max_uses"`
	UsesCount int `gorm:"column:uses_count;not null;default:0"`
	ValidFrom string `gorm:"column:valid_from;not null"`
	ValidUntil string `gorm:"column:valid_until;not null"`
	IsActive bool `gorm:"column:is_active;default:true"`
}

func (m *Coupon) ToResponse() CouponResponse {
	return CouponResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
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

func (m *Coupon) ApplyUpdate(req CouponUpdateRequest) {
	if req.Code != nil { m.Code = *req.Code }
	if req.DiscountType != nil { m.DiscountType = *req.DiscountType }
	if req.DiscountValue != nil { m.DiscountValue = *req.DiscountValue }
	if req.MinOrderValue != nil { m.MinOrderValue = *req.MinOrderValue }
	if req.MaxUses != nil { m.MaxUses = req.MaxUses }
	if req.UsesCount != nil { m.UsesCount = *req.UsesCount }
	if req.ValidFrom != nil { m.ValidFrom = *req.ValidFrom }
	if req.ValidUntil != nil { m.ValidUntil = *req.ValidUntil }
	if req.IsActive != nil { m.IsActive = *req.IsActive }
}

func (m *Coupon) IsValid()  (bool, error) {
	return false, fmt.Errorf("IsValid: not implemented")
}

func (m *Coupon) IsApplicableToOrder(orderTotal float64)  (bool, error) {
	return false, fmt.Errorf("IsApplicableToOrder: not implemented")
}

func (m *Coupon) Redeem()  error {
	return fmt.Errorf("Redeem: not implemented")
}

func (m *Coupon) Deactivate()  error {
	return fmt.Errorf("Deactivate: not implemented")
}
