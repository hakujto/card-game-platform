package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type AchievementRarityType string
const (
	AchievementRarityType_Common AchievementRarityType = "Common"
	AchievementRarityType_Uncommon AchievementRarityType = "Uncommon"
	AchievementRarityType_Rare AchievementRarityType = "Rare"
	AchievementRarityType_Epic AchievementRarityType = "Epic"
	AchievementRarityType_Legendary AchievementRarityType = "Legendary"
)

// AchievementCreateRequest is the POST body.
type AchievementCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Description string `json:"description" binding:"required"`
	IconUrl *string `json:"icon_url"`
	Points int `json:"points"`
	Rarity AchievementRarityType `json:"rarity" binding:"required"`
	IsHidden bool `json:"is_hidden"`
}

// AchievementUpdateRequest is the PUT/PATCH body — all fields optional.
type AchievementUpdateRequest struct {
	Name *string `json:"name"`
	Description *string `json:"description"`
	IconUrl *string `json:"icon_url"`
	Points *int `json:"points"`
	Rarity *AchievementRarityType `json:"rarity"`
	IsHidden *bool `json:"is_hidden"`
}

// AchievementResponse is the JSON representation returned by the API.
type AchievementResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Description string `json:"description"`
	IconUrl *string `json:"icon_url"`
	Points int `json:"points"`
	Rarity AchievementRarityType `json:"rarity"`
	IsHidden bool `json:"is_hidden"`
}

type Achievement struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Description string `gorm:"column:description;type:text;not null"`
	IconUrl *string `gorm:"column:icon_url"`
	Points int `gorm:"column:points;not null;default:10"`
	Rarity AchievementRarityType `gorm:"column:rarity;not null;default:'Common'"`
	IsHidden bool `gorm:"column:is_hidden;default:false"`
}

func (m *Achievement) ToResponse() AchievementResponse {
	return AchievementResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Description: m.Description,
		IconUrl: m.IconUrl,
		Points: m.Points,
		Rarity: m.Rarity,
		IsHidden: m.IsHidden,
	}
}

func (m *Achievement) ApplyUpdate(req AchievementUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Description != nil { m.Description = *req.Description }
	if req.IconUrl != nil { m.IconUrl = req.IconUrl }
	if req.Points != nil { m.Points = *req.Points }
	if req.Rarity != nil { m.Rarity = *req.Rarity }
	if req.IsHidden != nil { m.IsHidden = *req.IsHidden }
}

func (m *Achievement) PointValue(multiplier int)  (int, error) {
	return 0, fmt.Errorf("PointValue: not implemented")
}

func (m *Achievement) Reveal()  error {
	return fmt.Errorf("Reveal: not implemented")
}
