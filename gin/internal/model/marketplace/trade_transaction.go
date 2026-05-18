package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type TradeTransactionStatusType string
const (
	TradeTransactionStatusType_Pending TradeTransactionStatusType = "Pending"
	TradeTransactionStatusType_Completed TradeTransactionStatusType = "Completed"
	TradeTransactionStatusType_Disputed TradeTransactionStatusType = "Disputed"
	TradeTransactionStatusType_Refunded TradeTransactionStatusType = "Refunded"
)

// TradeTransactionCreateRequest is the POST body.
type TradeTransactionCreateRequest struct {
	FinalPrice types.Decimal `json:"final_price"`
	PlatformFee types.Decimal `json:"platform_fee"`
	Status TradeTransactionStatusType `json:"status" binding:"required"`
	CompletedAt *string `json:"completed_at"`
	ListingID uint `json:"listing_id"`
	BuyerID uint `json:"buyer_id"`
	SellerID uint `json:"seller_id"`
}

// TradeTransactionUpdateRequest is the PUT/PATCH body — all fields optional.
type TradeTransactionUpdateRequest struct {
	FinalPrice *types.Decimal `json:"final_price"`
	PlatformFee *types.Decimal `json:"platform_fee"`
	Status *TradeTransactionStatusType `json:"status"`
	CompletedAt *string `json:"completed_at"`
	ListingID *uint `json:"listing_id"`
	BuyerID *uint `json:"buyer_id"`
	SellerID *uint `json:"seller_id"`
}

// TradeTransactionResponse is the JSON representation returned by the API.
type TradeTransactionResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	FinalPrice types.Decimal `json:"final_price"`
	PlatformFee types.Decimal `json:"platform_fee"`
	Status TradeTransactionStatusType `json:"status"`
	CompletedAt *string `json:"completed_at"`
	ListingID uint `json:"listing_id"`
	BuyerID uint `json:"buyer_id"`
	SellerID uint `json:"seller_id"`
}

type TradeTransaction struct {
	gorm.Model
	FinalPrice types.Decimal `gorm:"column:final_price;type:decimal(10,2);not null"`
	PlatformFee types.Decimal `gorm:"column:platform_fee;type:decimal(10,2);not null"`
	Status TradeTransactionStatusType `gorm:"column:status;not null;default:'Pending'"`
	CompletedAt *string `gorm:"column:completed_at"`
	ListingID uint `gorm:"column:listing_id"`
	BuyerID uint `gorm:"column:buyer_id"`
	SellerID uint `gorm:"column:seller_id"`
}

func (m *TradeTransaction) ToResponse() TradeTransactionResponse {
	return TradeTransactionResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		FinalPrice: m.FinalPrice,
		PlatformFee: m.PlatformFee,
		Status: m.Status,
		CompletedAt: m.CompletedAt,
		ListingID: m.ListingID,
		BuyerID: m.BuyerID,
		SellerID: m.SellerID,
	}
}

func (m *TradeTransaction) ApplyUpdate(req TradeTransactionUpdateRequest) {
	if req.FinalPrice != nil { m.FinalPrice = *req.FinalPrice }
	if req.PlatformFee != nil { m.PlatformFee = *req.PlatformFee }
	if req.Status != nil { m.Status = *req.Status }
	if req.CompletedAt != nil { m.CompletedAt = req.CompletedAt }
	if req.ListingID != nil { m.ListingID = *req.ListingID }
	if req.BuyerID != nil { m.BuyerID = *req.BuyerID }
	if req.SellerID != nil { m.SellerID = *req.SellerID }
}

func (m *TradeTransaction) Complete()  error {
	return fmt.Errorf("Complete: not implemented")
}

func (m *TradeTransaction) Refund()  error {
	return fmt.Errorf("Refund: not implemented")
}

func (m *TradeTransaction) OpenDispute(reason string)  error {
	return fmt.Errorf("OpenDispute: not implemented")
}

func (m *TradeTransaction) SellerNet()  (float64, error) {
	return 0.0, fmt.Errorf("SellerNet: not implemented")
}
