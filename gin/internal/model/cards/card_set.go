package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type CardSetSetTypeType string
const (
	CardSetSetTypeType_Core CardSetSetTypeType = "Core"
	CardSetSetTypeType_Expansion CardSetSetTypeType = "Expansion"
	CardSetSetTypeType_Supplemental CardSetSetTypeType = "Supplemental"
	CardSetSetTypeType_Masters CardSetSetTypeType = "Masters"
	CardSetSetTypeType_Draft CardSetSetTypeType = "Draft"
)

// CardSetCreateRequest is the POST body.
type CardSetCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Code string `json:"code" binding:"required"`
	ReleaseDate string `json:"release_date" binding:"required"`
	RotationDate *string `json:"rotation_date"`
	SetType CardSetSetTypeType `json:"set_type" binding:"required"`
	TotalCards int `json:"total_cards"`
	IsRotated bool `json:"is_rotated"`
	Description *string `json:"description"`
	LogoUrl *string `json:"logo_url"`
}

// CardSetUpdateRequest is the PUT/PATCH body — all fields optional.
type CardSetUpdateRequest struct {
	Name *string `json:"name"`
	Code *string `json:"code"`
	ReleaseDate *string `json:"release_date"`
	RotationDate *string `json:"rotation_date"`
	SetType *CardSetSetTypeType `json:"set_type"`
	TotalCards *int `json:"total_cards"`
	IsRotated *bool `json:"is_rotated"`
	Description *string `json:"description"`
	LogoUrl *string `json:"logo_url"`
}

// CardSetResponse is the JSON representation returned by the API.
type CardSetResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Code string `json:"code"`
	ReleaseDate string `json:"release_date"`
	RotationDate *string `json:"rotation_date"`
	SetType CardSetSetTypeType `json:"set_type"`
	TotalCards int `json:"total_cards"`
	IsRotated bool `json:"is_rotated"`
	Description *string `json:"description"`
	LogoUrl *string `json:"logo_url"`
}

type CardSet struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Code string `gorm:"column:code;not null"`
	ReleaseDate string `gorm:"column:release_date;not null"`
	RotationDate *string `gorm:"column:rotation_date"`
	SetType CardSetSetTypeType `gorm:"column:set_type;not null;default:'Expansion'"`
	TotalCards int `gorm:"column:total_cards;not null"`
	IsRotated bool `gorm:"column:is_rotated;default:false"`
	Description *string `gorm:"column:description;type:text"`
	LogoUrl *string `gorm:"column:logo_url"`
}

func (m *CardSet) ToResponse() CardSetResponse {
	return CardSetResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Code: m.Code,
		ReleaseDate: m.ReleaseDate,
		RotationDate: m.RotationDate,
		SetType: m.SetType,
		TotalCards: m.TotalCards,
		IsRotated: m.IsRotated,
		Description: m.Description,
		LogoUrl: m.LogoUrl,
	}
}

func (m *CardSet) ApplyUpdate(req CardSetUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Code != nil { m.Code = *req.Code }
	if req.ReleaseDate != nil { m.ReleaseDate = *req.ReleaseDate }
	if req.RotationDate != nil { m.RotationDate = req.RotationDate }
	if req.SetType != nil { m.SetType = *req.SetType }
	if req.TotalCards != nil { m.TotalCards = *req.TotalCards }
	if req.IsRotated != nil { m.IsRotated = *req.IsRotated }
	if req.Description != nil { m.Description = req.Description }
	if req.LogoUrl != nil { m.LogoUrl = req.LogoUrl }
}

func (m *CardSet) IsLegalInStandard()  (bool, error) {
	return false, fmt.Errorf("IsLegalInStandard: not implemented")
}

func (m *CardSet) IsLegalInFormat(format string)  (bool, error) {
	return false, fmt.Errorf("IsLegalInFormat: not implemented")
}

func (m *CardSet) CardCountByRarity(rarity string)  (int, error) {
	return 0, fmt.Errorf("CardCountByRarity: not implemented")
}

func (m *CardSet) RotateOut()  error {
	return fmt.Errorf("RotateOut: not implemented")
}
