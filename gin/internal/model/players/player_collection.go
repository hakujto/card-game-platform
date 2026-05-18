package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type PlayerCollectionConditionType string
const (
	PlayerCollectionConditionType_Mint PlayerCollectionConditionType = "Mint"
	PlayerCollectionConditionType_NearMint PlayerCollectionConditionType = "NearMint"
	PlayerCollectionConditionType_Excellent PlayerCollectionConditionType = "Excellent"
	PlayerCollectionConditionType_Good PlayerCollectionConditionType = "Good"
	PlayerCollectionConditionType_Played PlayerCollectionConditionType = "Played"
)

type PlayerCollectionAcquiredViaType string
const (
	PlayerCollectionAcquiredViaType_Purchase PlayerCollectionAcquiredViaType = "Purchase"
	PlayerCollectionAcquiredViaType_Trade PlayerCollectionAcquiredViaType = "Trade"
	PlayerCollectionAcquiredViaType_TournamentReward PlayerCollectionAcquiredViaType = "TournamentReward"
	PlayerCollectionAcquiredViaType_Pack PlayerCollectionAcquiredViaType = "Pack"
	PlayerCollectionAcquiredViaType_Craft PlayerCollectionAcquiredViaType = "Craft"
)

// PlayerCollectionCreateRequest is the POST body.
type PlayerCollectionCreateRequest struct {
	Quantity int `json:"quantity"`
	Foil bool `json:"foil"`
	Condition PlayerCollectionConditionType `json:"condition" binding:"required"`
	AcquiredAt string `json:"acquired_at" binding:"required"`
	AcquiredVia PlayerCollectionAcquiredViaType `json:"acquired_via" binding:"required"`
	PlayerID uint `json:"player_id"`
	CardID uint `json:"card_id"`
}

// PlayerCollectionUpdateRequest is the PUT/PATCH body — all fields optional.
type PlayerCollectionUpdateRequest struct {
	Quantity *int `json:"quantity"`
	Foil *bool `json:"foil"`
	Condition *PlayerCollectionConditionType `json:"condition"`
	AcquiredAt *string `json:"acquired_at"`
	AcquiredVia *PlayerCollectionAcquiredViaType `json:"acquired_via"`
	PlayerID *uint `json:"player_id"`
	CardID *uint `json:"card_id"`
}

// PlayerCollectionResponse is the JSON representation returned by the API.
type PlayerCollectionResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Quantity int `json:"quantity"`
	Foil bool `json:"foil"`
	Condition PlayerCollectionConditionType `json:"condition"`
	AcquiredAt string `json:"acquired_at"`
	AcquiredVia PlayerCollectionAcquiredViaType `json:"acquired_via"`
	PlayerID uint `json:"player_id"`
	CardID uint `json:"card_id"`
}

type PlayerCollection struct {
	gorm.Model
	Quantity int `gorm:"column:quantity;not null;default:1"`
	Foil bool `gorm:"column:foil;default:false"`
	Condition PlayerCollectionConditionType `gorm:"column:condition;not null;default:'Mint'"`
	AcquiredAt string `gorm:"column:acquired_at;not null"`
	AcquiredVia PlayerCollectionAcquiredViaType `gorm:"column:acquired_via;not null;default:'Purchase'"`
	PlayerID uint `gorm:"column:player_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *PlayerCollection) ToResponse() PlayerCollectionResponse {
	return PlayerCollectionResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Quantity: m.Quantity,
		Foil: m.Foil,
		Condition: m.Condition,
		AcquiredAt: m.AcquiredAt,
		AcquiredVia: m.AcquiredVia,
		PlayerID: m.PlayerID,
		CardID: m.CardID,
	}
}

func (m *PlayerCollection) ApplyUpdate(req PlayerCollectionUpdateRequest) {
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.Foil != nil { m.Foil = *req.Foil }
	if req.Condition != nil { m.Condition = *req.Condition }
	if req.AcquiredAt != nil { m.AcquiredAt = *req.AcquiredAt }
	if req.AcquiredVia != nil { m.AcquiredVia = *req.AcquiredVia }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *PlayerCollection) Add(quantity int)  error {
	return fmt.Errorf("Add: not implemented")
}

func (m *PlayerCollection) Remove(quantity int)  error {
	return fmt.Errorf("Remove: not implemented")
}

func (m *PlayerCollection) EstimatedValue()  (float64, error) {
	return 0.0, fmt.Errorf("EstimatedValue: not implemented")
}
