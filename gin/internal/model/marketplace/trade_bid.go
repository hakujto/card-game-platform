package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

// TradeBidCreateRequest is the POST body.
type TradeBidCreateRequest struct {
	Amount types.Decimal `json:"amount"`
	PlacedAt string `json:"placed_at" binding:"required"`
	IsWinning bool `json:"is_winning"`
	ListingID uint `json:"listing_id"`
	BidderID uint `json:"bidder_id"`
}

// TradeBidUpdateRequest is the PUT/PATCH body — all fields optional.
type TradeBidUpdateRequest struct {
	Amount *types.Decimal `json:"amount"`
	PlacedAt *string `json:"placed_at"`
	IsWinning *bool `json:"is_winning"`
	ListingID *uint `json:"listing_id"`
	BidderID *uint `json:"bidder_id"`
}

// TradeBidResponse is the JSON representation returned by the API.
type TradeBidResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Amount types.Decimal `json:"amount"`
	PlacedAt string `json:"placed_at"`
	IsWinning bool `json:"is_winning"`
	ListingID uint `json:"listing_id"`
	BidderID uint `json:"bidder_id"`
}

type TradeBid struct {
	gorm.Model
	Amount types.Decimal `gorm:"column:amount;type:decimal(10,2);not null"`
	PlacedAt string `gorm:"column:placed_at;not null"`
	IsWinning bool `gorm:"column:is_winning;default:false"`
	ListingID uint `gorm:"column:listing_id"`
	BidderID uint `gorm:"column:bidder_id"`
}

func (m *TradeBid) ToResponse() TradeBidResponse {
	return TradeBidResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Amount: m.Amount,
		PlacedAt: m.PlacedAt,
		IsWinning: m.IsWinning,
		ListingID: m.ListingID,
		BidderID: m.BidderID,
	}
}

func (m *TradeBid) ApplyUpdate(req TradeBidUpdateRequest) {
	if req.Amount != nil { m.Amount = *req.Amount }
	if req.PlacedAt != nil { m.PlacedAt = *req.PlacedAt }
	if req.IsWinning != nil { m.IsWinning = *req.IsWinning }
	if req.ListingID != nil { m.ListingID = *req.ListingID }
	if req.BidderID != nil { m.BidderID = *req.BidderID }
}

func (m *TradeBid) OutbidBy(newAmount float64)  (bool, error) {
	return false, fmt.Errorf("OutbidBy: not implemented")
}

func (m *TradeBid) Retract()  error {
	return fmt.Errorf("Retract: not implemented")
}
