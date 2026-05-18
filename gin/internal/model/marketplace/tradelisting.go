package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type TradelistingListingTypeType string
const (
	TradelistingListingTypeType_FixedPrice TradelistingListingTypeType = "FixedPrice"
	TradelistingListingTypeType_Auction TradelistingListingTypeType = "Auction"
	TradelistingListingTypeType_TradeOffer TradelistingListingTypeType = "TradeOffer"
)

type TradelistingConditionType string
const (
	TradelistingConditionType_Mint TradelistingConditionType = "Mint"
	TradelistingConditionType_NearMint TradelistingConditionType = "NearMint"
	TradelistingConditionType_Excellent TradelistingConditionType = "Excellent"
	TradelistingConditionType_Good TradelistingConditionType = "Good"
	TradelistingConditionType_Played TradelistingConditionType = "Played"
)

type TradelistingStatusType string
const (
	TradelistingStatusType_Active TradelistingStatusType = "Active"
	TradelistingStatusType_Sold TradelistingStatusType = "Sold"
	TradelistingStatusType_Expired TradelistingStatusType = "Expired"
	TradelistingStatusType_Cancelled TradelistingStatusType = "Cancelled"
	TradelistingStatusType_Pending TradelistingStatusType = "Pending"
)

// TradelistingCreateRequest is the POST body.
type TradelistingCreateRequest struct {
	ListingType TradelistingListingTypeType `json:"listing_type" binding:"required"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil bool `json:"foil"`
	Condition TradelistingConditionType `json:"condition" binding:"required"`
	Quantity int `json:"quantity"`
	Status TradelistingStatusType `json:"status" binding:"required"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID uint `json:"seller_id"`
	CardID uint `json:"card_id"`
}

// TradelistingUpdateRequest is the PUT/PATCH body — all fields optional.
type TradelistingUpdateRequest struct {
	ListingType *TradelistingListingTypeType `json:"listing_type"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil *bool `json:"foil"`
	Condition *TradelistingConditionType `json:"condition"`
	Quantity *int `json:"quantity"`
	Status *TradelistingStatusType `json:"status"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID *uint `json:"seller_id"`
	CardID *uint `json:"card_id"`
}

// TradelistingResponse is the JSON representation returned by the API.
type TradelistingResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	ListingType TradelistingListingTypeType `json:"listing_type"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil bool `json:"foil"`
	Condition TradelistingConditionType `json:"condition"`
	Quantity int `json:"quantity"`
	Status TradelistingStatusType `json:"status"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID uint `json:"seller_id"`
	CardID uint `json:"card_id"`
}

type Tradelisting struct {
	gorm.Model
	ListingType TradelistingListingTypeType `gorm:"column:listing_type;not null;default:'FixedPrice'"`
	AskingPrice *types.Decimal `gorm:"column:asking_price;type:decimal(10,2)"`
	AuctionStartPrice *types.Decimal `gorm:"column:auction_start_price;type:decimal(10,2)"`
	AuctionCurrentBid *types.Decimal `gorm:"column:auction_current_bid;type:decimal(10,2)"`
	AuctionEndTime *string `gorm:"column:auction_end_time"`
	Foil bool `gorm:"column:foil;default:false"`
	Condition TradelistingConditionType `gorm:"column:condition;not null;default:'Mint'"`
	Quantity int `gorm:"column:quantity;not null;default:1"`
	Status TradelistingStatusType `gorm:"column:status;not null;default:'Active'"`
	Description *string `gorm:"column:description;type:text"`
	ExpiresAt *string `gorm:"column:expires_at"`
	SellerID uint `gorm:"column:seller_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *Tradelisting) ToResponse() TradelistingResponse {
	return TradelistingResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		ListingType: m.ListingType,
		AskingPrice: m.AskingPrice,
		AuctionStartPrice: m.AuctionStartPrice,
		AuctionCurrentBid: m.AuctionCurrentBid,
		AuctionEndTime: m.AuctionEndTime,
		Foil: m.Foil,
		Condition: m.Condition,
		Quantity: m.Quantity,
		Status: m.Status,
		Description: m.Description,
		ExpiresAt: m.ExpiresAt,
		SellerID: m.SellerID,
		CardID: m.CardID,
	}
}

func (m *Tradelisting) ApplyUpdate(req TradelistingUpdateRequest) {
	if req.ListingType != nil { m.ListingType = *req.ListingType }
	if req.AskingPrice != nil { m.AskingPrice = req.AskingPrice }
	if req.AuctionStartPrice != nil { m.AuctionStartPrice = req.AuctionStartPrice }
	if req.AuctionCurrentBid != nil { m.AuctionCurrentBid = req.AuctionCurrentBid }
	if req.AuctionEndTime != nil { m.AuctionEndTime = req.AuctionEndTime }
	if req.Foil != nil { m.Foil = *req.Foil }
	if req.Condition != nil { m.Condition = *req.Condition }
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.Status != nil { m.Status = *req.Status }
	if req.Description != nil { m.Description = req.Description }
	if req.ExpiresAt != nil { m.ExpiresAt = req.ExpiresAt }
	if req.SellerID != nil { m.SellerID = *req.SellerID }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *Tradelisting) Close()  error {
	return fmt.Errorf("Close: not implemented")
}

func (m *Tradelisting) Extend(days int)  error {
	return fmt.Errorf("Extend: not implemented")
}

func (m *Tradelisting) Cancel()  error {
	return fmt.Errorf("Cancel: not implemented")
}

func (m *Tradelisting) IsExpired()  (bool, error) {
	return false, fmt.Errorf("IsExpired: not implemented")
}

func (m *Tradelisting) FinalizeAuction()  error {
	return fmt.Errorf("FinalizeAuction: not implemented")
}
