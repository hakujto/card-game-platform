package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type SeasonFormatType string
const (
	SeasonFormatType_Standard SeasonFormatType = "Standard"
	SeasonFormatType_Extended SeasonFormatType = "Extended"
	SeasonFormatType_Legacy SeasonFormatType = "Legacy"
	SeasonFormatType_Vintage SeasonFormatType = "Vintage"
	SeasonFormatType_Commander SeasonFormatType = "Commander"
	SeasonFormatType_Draft SeasonFormatType = "Draft"
)

// SeasonCreateRequest is the POST body.
type SeasonCreateRequest struct {
	Name string `json:"name" binding:"required"`
	StartDate string `json:"start_date" binding:"required"`
	EndDate string `json:"end_date" binding:"required"`
	Format SeasonFormatType `json:"format" binding:"required"`
	IsActive bool `json:"is_active"`
	RewardDescription *string `json:"reward_description"`
}

// SeasonUpdateRequest is the PUT/PATCH body — all fields optional.
type SeasonUpdateRequest struct {
	Name *string `json:"name"`
	StartDate *string `json:"start_date"`
	EndDate *string `json:"end_date"`
	Format *SeasonFormatType `json:"format"`
	IsActive *bool `json:"is_active"`
	RewardDescription *string `json:"reward_description"`
}

// SeasonResponse is the JSON representation returned by the API.
type SeasonResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	StartDate string `json:"start_date"`
	EndDate string `json:"end_date"`
	Format SeasonFormatType `json:"format"`
	IsActive bool `json:"is_active"`
	RewardDescription *string `json:"reward_description"`
}

type Season struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	StartDate string `gorm:"column:start_date;not null"`
	EndDate string `gorm:"column:end_date;not null"`
	Format SeasonFormatType `gorm:"column:format;not null;default:'Standard'"`
	IsActive bool `gorm:"column:is_active;default:false"`
	RewardDescription *string `gorm:"column:reward_description;type:text"`
}

func (m *Season) ToResponse() SeasonResponse {
	return SeasonResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		StartDate: m.StartDate,
		EndDate: m.EndDate,
		Format: m.Format,
		IsActive: m.IsActive,
		RewardDescription: m.RewardDescription,
	}
}

func (m *Season) ApplyUpdate(req SeasonUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.StartDate != nil { m.StartDate = *req.StartDate }
	if req.EndDate != nil { m.EndDate = *req.EndDate }
	if req.Format != nil { m.Format = *req.Format }
	if req.IsActive != nil { m.IsActive = *req.IsActive }
	if req.RewardDescription != nil { m.RewardDescription = req.RewardDescription }
}

func (m *Season) Activate()  error {
	return fmt.Errorf("Activate: not implemented")
}

func (m *Season) Deactivate()  error {
	return fmt.Errorf("Deactivate: not implemented")
}

func (m *Season) FinalizeRewards()  error {
	return fmt.Errorf("FinalizeRewards: not implemented")
}

func (m *Season) IsOngoing()  (bool, error) {
	return false, fmt.Errorf("IsOngoing: not implemented")
}
