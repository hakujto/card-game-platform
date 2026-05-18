package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type CardAbilityAbilityTypeType string
const (
	CardAbilityAbilityTypeType_Keyword CardAbilityAbilityTypeType = "Keyword"
	CardAbilityAbilityTypeType_Activated CardAbilityAbilityTypeType = "Activated"
	CardAbilityAbilityTypeType_Triggered CardAbilityAbilityTypeType = "Triggered"
	CardAbilityAbilityTypeType_Static CardAbilityAbilityTypeType = "Static"
)

type CardAbilityTimingType string
const (
	CardAbilityTimingType_Any CardAbilityTimingType = "Any"
	CardAbilityTimingType_Sorcery CardAbilityTimingType = "Sorcery"
	CardAbilityTimingType_Instant CardAbilityTimingType = "Instant"
	CardAbilityTimingType_Combat CardAbilityTimingType = "Combat"
)

// CardAbilityCreateRequest is the POST body.
type CardAbilityCreateRequest struct {
	AbilityType CardAbilityAbilityTypeType `json:"ability_type" binding:"required"`
	Keyword *string `json:"keyword"`
	AbilityText string `json:"ability_text" binding:"required"`
	Timing *CardAbilityTimingType `json:"timing"`
	CardID uint `json:"card_id"`
}

// CardAbilityUpdateRequest is the PUT/PATCH body — all fields optional.
type CardAbilityUpdateRequest struct {
	AbilityType *CardAbilityAbilityTypeType `json:"ability_type"`
	Keyword *string `json:"keyword"`
	AbilityText *string `json:"ability_text"`
	Timing *CardAbilityTimingType `json:"timing"`
	CardID *uint `json:"card_id"`
}

// CardAbilityResponse is the JSON representation returned by the API.
type CardAbilityResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	AbilityType CardAbilityAbilityTypeType `json:"ability_type"`
	Keyword *string `json:"keyword"`
	AbilityText string `json:"ability_text"`
	Timing *CardAbilityTimingType `json:"timing"`
	CardID uint `json:"card_id"`
}

type CardAbility struct {
	gorm.Model
	AbilityType CardAbilityAbilityTypeType `gorm:"column:ability_type;not null;default:'Keyword'"`
	Keyword *string `gorm:"column:keyword"`
	AbilityText string `gorm:"column:ability_text;type:text;not null"`
	Timing *CardAbilityTimingType `gorm:"column:timing"`
	CardID uint `gorm:"column:card_id"`
}

func (m *CardAbility) ToResponse() CardAbilityResponse {
	return CardAbilityResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		AbilityType: m.AbilityType,
		Keyword: m.Keyword,
		AbilityText: m.AbilityText,
		Timing: m.Timing,
		CardID: m.CardID,
	}
}

func (m *CardAbility) ApplyUpdate(req CardAbilityUpdateRequest) {
	if req.AbilityType != nil { m.AbilityType = *req.AbilityType }
	if req.Keyword != nil { m.Keyword = req.Keyword }
	if req.AbilityText != nil { m.AbilityText = *req.AbilityText }
	if req.Timing != nil { m.Timing = req.Timing }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *CardAbility) IsUsableAt(timing string)  (bool, error) {
	return false, fmt.Errorf("IsUsableAt: not implemented")
}

func (m *CardAbility) Describe()  (string, error) {
	return "", fmt.Errorf("Describe: not implemented")
}
