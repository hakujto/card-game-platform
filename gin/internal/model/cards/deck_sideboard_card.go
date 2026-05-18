package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DeckSideboardCardCreateRequest is the POST body.
type DeckSideboardCardCreateRequest struct {
	Quantity int `json:"quantity"`
	DeckID uint `json:"deck_id"`
	CardID uint `json:"card_id"`
}

// DeckSideboardCardUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckSideboardCardUpdateRequest struct {
	Quantity *int `json:"quantity"`
	DeckID *uint `json:"deck_id"`
	CardID *uint `json:"card_id"`
}

// DeckSideboardCardResponse is the JSON representation returned by the API.
type DeckSideboardCardResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Quantity int `json:"quantity"`
	DeckID uint `json:"deck_id"`
	CardID uint `json:"card_id"`
}

type DeckSideboardCard struct {
	gorm.Model
	Quantity int `gorm:"column:quantity;not null;default:1"`
	DeckID uint `gorm:"column:deck_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *DeckSideboardCard) ToResponse() DeckSideboardCardResponse {
	return DeckSideboardCardResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Quantity: m.Quantity,
		DeckID: m.DeckID,
		CardID: m.CardID,
	}
}

func (m *DeckSideboardCard) ApplyUpdate(req DeckSideboardCardUpdateRequest) {
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.DeckID != nil { m.DeckID = *req.DeckID }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *DeckSideboardCard) Increment(amount int)  error {
	return fmt.Errorf("Increment: not implemented")
}

func (m *DeckSideboardCard) Decrement(amount int)  error {
	return fmt.Errorf("Decrement: not implemented")
}
