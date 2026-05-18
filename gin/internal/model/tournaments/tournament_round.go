package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type TournamentRoundStatusType string
const (
	TournamentRoundStatusType_Pending TournamentRoundStatusType = "Pending"
	TournamentRoundStatusType_Active TournamentRoundStatusType = "Active"
	TournamentRoundStatusType_Completed TournamentRoundStatusType = "Completed"
)

// TournamentRoundCreateRequest is the POST body.
type TournamentRoundCreateRequest struct {
	RoundNumber int `json:"round_number"`
	Status TournamentRoundStatusType `json:"status" binding:"required"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	TimeLimitMinutes int `json:"time_limit_minutes"`
	TournamentID uint `json:"tournament_id"`
}

// TournamentRoundUpdateRequest is the PUT/PATCH body — all fields optional.
type TournamentRoundUpdateRequest struct {
	RoundNumber *int `json:"round_number"`
	Status *TournamentRoundStatusType `json:"status"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	TimeLimitMinutes *int `json:"time_limit_minutes"`
	TournamentID *uint `json:"tournament_id"`
}

// TournamentRoundResponse is the JSON representation returned by the API.
type TournamentRoundResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	RoundNumber int `json:"round_number"`
	Status TournamentRoundStatusType `json:"status"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	TimeLimitMinutes int `json:"time_limit_minutes"`
	TournamentID uint `json:"tournament_id"`
}

type TournamentRound struct {
	gorm.Model
	RoundNumber int `gorm:"column:round_number;not null"`
	Status TournamentRoundStatusType `gorm:"column:status;not null;default:'Pending'"`
	StartedAt *string `gorm:"column:started_at"`
	EndedAt *string `gorm:"column:ended_at"`
	TimeLimitMinutes int `gorm:"column:time_limit_minutes;not null;default:50"`
	TournamentID uint `gorm:"column:tournament_id"`
}

func (m *TournamentRound) ToResponse() TournamentRoundResponse {
	return TournamentRoundResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		RoundNumber: m.RoundNumber,
		Status: m.Status,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		TimeLimitMinutes: m.TimeLimitMinutes,
		TournamentID: m.TournamentID,
	}
}

func (m *TournamentRound) ApplyUpdate(req TournamentRoundUpdateRequest) {
	if req.RoundNumber != nil { m.RoundNumber = *req.RoundNumber }
	if req.Status != nil { m.Status = *req.Status }
	if req.StartedAt != nil { m.StartedAt = req.StartedAt }
	if req.EndedAt != nil { m.EndedAt = req.EndedAt }
	if req.TimeLimitMinutes != nil { m.TimeLimitMinutes = *req.TimeLimitMinutes }
	if req.TournamentID != nil { m.TournamentID = *req.TournamentID }
}

func (m *TournamentRound) Start()  error {
	return fmt.Errorf("Start: not implemented")
}

func (m *TournamentRound) Complete()  error {
	return fmt.Errorf("Complete: not implemented")
}

func (m *TournamentRound) GeneratePairings()  error {
	return fmt.Errorf("GeneratePairings: not implemented")
}

func (m *TournamentRound) IsTimeExpired()  (bool, error) {
	return false, fmt.Errorf("IsTimeExpired: not implemented")
}
