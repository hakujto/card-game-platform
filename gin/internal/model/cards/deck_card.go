package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DeckCardCreateRequest is the POST body.
type DeckCardCreateRequest struct {
	Quantity int `json:"quantity"`
	IsCommander bool `json:"is_commander"`
	DeckID uint `json:"deck_id"`
	CardID uint `json:"card_id"`
}

// DeckCardUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckCardUpdateRequest struct {
	Quantity *int `json:"quantity"`
	IsCommander *bool `json:"is_commander"`
	DeckID *uint `json:"deck_id"`
	CardID *uint `json:"card_id"`
}

// DeckCardResponse is the JSON representation returned by the API.
type DeckCardResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Quantity int `json:"quantity"`
	IsCommander bool `json:"is_commander"`
	DeckID uint `json:"deck_id"`
	CardID uint `json:"card_id"`
}

type DeckCard struct {
	gorm.Model
	Quantity int `gorm:"column:quantity;not null;default:1"`
	IsCommander bool `gorm:"column:is_commander;default:false"`
	DeckID uint `gorm:"column:deck_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *DeckCard) ToResponse() DeckCardResponse {
	return DeckCardResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Quantity: m.Quantity,
		IsCommander: m.IsCommander,
		DeckID: m.DeckID,
		CardID: m.CardID,
	}
}

func (m *DeckCard) ApplyUpdate(req DeckCardUpdateRequest) {
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.IsCommander != nil { m.IsCommander = *req.IsCommander }
	if req.DeckID != nil { m.DeckID = *req.DeckID }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *DeckCard) Increment(amount int)  error {
	return fmt.Errorf("Increment: not implemented")
}

func (m *DeckCard) Decrement(amount int)  error {
	return fmt.Errorf("Decrement: not implemented")
}
