package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

// CardPriceHistoryCreateRequest is the POST body.
type CardPriceHistoryCreateRequest struct {
	PriceDate string `json:"price_date" binding:"required"`
	AvgPrice types.Decimal `json:"avg_price"`
	MinPrice types.Decimal `json:"min_price"`
	MaxPrice types.Decimal `json:"max_price"`
	Volume int `json:"volume"`
	Foil bool `json:"foil"`
	CardID uint `json:"card_id"`
}

// CardPriceHistoryUpdateRequest is the PUT/PATCH body — all fields optional.
type CardPriceHistoryUpdateRequest struct {
	PriceDate *string `json:"price_date"`
	AvgPrice *types.Decimal `json:"avg_price"`
	MinPrice *types.Decimal `json:"min_price"`
	MaxPrice *types.Decimal `json:"max_price"`
	Volume *int `json:"volume"`
	Foil *bool `json:"foil"`
	CardID *uint `json:"card_id"`
}

// CardPriceHistoryResponse is the JSON representation returned by the API.
type CardPriceHistoryResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	PriceDate string `json:"price_date"`
	AvgPrice types.Decimal `json:"avg_price"`
	MinPrice types.Decimal `json:"min_price"`
	MaxPrice types.Decimal `json:"max_price"`
	Volume int `json:"volume"`
	Foil bool `json:"foil"`
	CardID uint `json:"card_id"`
}

type CardPriceHistory struct {
	gorm.Model
	PriceDate string `gorm:"column:price_date;not null"`
	AvgPrice types.Decimal `gorm:"column:avg_price;type:decimal(10,2);not null"`
	MinPrice types.Decimal `gorm:"column:min_price;type:decimal(10,2);not null"`
	MaxPrice types.Decimal `gorm:"column:max_price;type:decimal(10,2);not null"`
	Volume int `gorm:"column:volume;not null"`
	Foil bool `gorm:"column:foil;default:false"`
	CardID uint `gorm:"column:card_id"`
}

func (m *CardPriceHistory) ToResponse() CardPriceHistoryResponse {
	return CardPriceHistoryResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		PriceDate: m.PriceDate,
		AvgPrice: m.AvgPrice,
		MinPrice: m.MinPrice,
		MaxPrice: m.MaxPrice,
		Volume: m.Volume,
		Foil: m.Foil,
		CardID: m.CardID,
	}
}

func (m *CardPriceHistory) ApplyUpdate(req CardPriceHistoryUpdateRequest) {
	if req.PriceDate != nil { m.PriceDate = *req.PriceDate }
	if req.AvgPrice != nil { m.AvgPrice = *req.AvgPrice }
	if req.MinPrice != nil { m.MinPrice = *req.MinPrice }
	if req.MaxPrice != nil { m.MaxPrice = *req.MaxPrice }
	if req.Volume != nil { m.Volume = *req.Volume }
	if req.Foil != nil { m.Foil = *req.Foil }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *CardPriceHistory) PriceChangePercent(previousAvg float64)  (float64, error) {
	return 0.0, fmt.Errorf("PriceChangePercent: not implemented")
}

func (m *CardPriceHistory) IsPriceSpike(thresholdPercent int)  (bool, error) {
	return false, fmt.Errorf("IsPriceSpike: not implemented")
}
