package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type TradeListingListingTypeType string
const (
	TradeListingListingTypeType_FixedPrice TradeListingListingTypeType = "FixedPrice"
	TradeListingListingTypeType_Auction TradeListingListingTypeType = "Auction"
	TradeListingListingTypeType_TradeOffer TradeListingListingTypeType = "TradeOffer"
)

type TradeListingConditionType string
const (
	TradeListingConditionType_Mint TradeListingConditionType = "Mint"
	TradeListingConditionType_NearMint TradeListingConditionType = "NearMint"
	TradeListingConditionType_Excellent TradeListingConditionType = "Excellent"
	TradeListingConditionType_Good TradeListingConditionType = "Good"
	TradeListingConditionType_Played TradeListingConditionType = "Played"
)

type TradeListingStatusType string
const (
	TradeListingStatusType_Active TradeListingStatusType = "Active"
	TradeListingStatusType_Sold TradeListingStatusType = "Sold"
	TradeListingStatusType_Expired TradeListingStatusType = "Expired"
	TradeListingStatusType_Cancelled TradeListingStatusType = "Cancelled"
	TradeListingStatusType_Pending TradeListingStatusType = "Pending"
)

// TradeListingCreateRequest is the POST body.
type TradeListingCreateRequest struct {
	ListingType TradeListingListingTypeType `json:"listing_type" binding:"required"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil bool `json:"foil"`
	Condition TradeListingConditionType `json:"condition" binding:"required"`
	Quantity int `json:"quantity"`
	Status TradeListingStatusType `json:"status" binding:"required"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID uint `json:"seller_id"`
	CardID uint `json:"card_id"`
}

// TradeListingUpdateRequest is the PUT/PATCH body — all fields optional.
type TradeListingUpdateRequest struct {
	ListingType *TradeListingListingTypeType `json:"listing_type"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil *bool `json:"foil"`
	Condition *TradeListingConditionType `json:"condition"`
	Quantity *int `json:"quantity"`
	Status *TradeListingStatusType `json:"status"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID *uint `json:"seller_id"`
	CardID *uint `json:"card_id"`
}

// TradeListingResponse is the JSON representation returned by the API.
type TradeListingResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	ListingType TradeListingListingTypeType `json:"listing_type"`
	AskingPrice *types.Decimal `json:"asking_price"`
	AuctionStartPrice *types.Decimal `json:"auction_start_price"`
	AuctionCurrentBid *types.Decimal `json:"auction_current_bid"`
	AuctionEndTime *string `json:"auction_end_time"`
	Foil bool `json:"foil"`
	Condition TradeListingConditionType `json:"condition"`
	Quantity int `json:"quantity"`
	Status TradeListingStatusType `json:"status"`
	Description *string `json:"description"`
	ExpiresAt *string `json:"expires_at"`
	SellerID uint `json:"seller_id"`
	CardID uint `json:"card_id"`
}

type TradeListing struct {
	gorm.Model
	ListingType TradeListingListingTypeType `gorm:"column:listing_type;not null;default:'FixedPrice'"`
	AskingPrice *types.Decimal `gorm:"column:asking_price;type:decimal(10,2)"`
	AuctionStartPrice *types.Decimal `gorm:"column:auction_start_price;type:decimal(10,2)"`
	AuctionCurrentBid *types.Decimal `gorm:"column:auction_current_bid;type:decimal(10,2)"`
	AuctionEndTime *string `gorm:"column:auction_end_time"`
	Foil bool `gorm:"column:foil;default:false"`
	Condition TradeListingConditionType `gorm:"column:condition;not null;default:'Mint'"`
	Quantity int `gorm:"column:quantity;not null;default:1"`
	Status TradeListingStatusType `gorm:"column:status;not null;default:'Active'"`
	Description *string `gorm:"column:description;type:text"`
	ExpiresAt *string `gorm:"column:expires_at"`
	SellerID uint `gorm:"column:seller_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *TradeListing) ToResponse() TradeListingResponse {
	return TradeListingResponse{
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

func (m *TradeListing) ApplyUpdate(req TradeListingUpdateRequest) {
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

func (m *TradeListing) Close()  error {
	return fmt.Errorf("Close: not implemented")
}

func (m *TradeListing) Extend(days int)  error {
	return fmt.Errorf("Extend: not implemented")
}

func (m *TradeListing) Cancel()  error {
	return fmt.Errorf("Cancel: not implemented")
}

func (m *TradeListing) IsExpired()  (bool, error) {
	return false, fmt.Errorf("IsExpired: not implemented")
}

func (m *TradeListing) FinalizeAuction()  error {
	return fmt.Errorf("FinalizeAuction: not implemented")
}
