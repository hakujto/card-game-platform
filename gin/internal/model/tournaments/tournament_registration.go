package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type TournamentRegistrationStatusType string
const (
	TournamentRegistrationStatusType_Registered TournamentRegistrationStatusType = "Registered"
	TournamentRegistrationStatusType_Waitlisted TournamentRegistrationStatusType = "Waitlisted"
	TournamentRegistrationStatusType_Withdrawn TournamentRegistrationStatusType = "Withdrawn"
	TournamentRegistrationStatusType_Disqualified TournamentRegistrationStatusType = "Disqualified"
)

// TournamentRegistrationCreateRequest is the POST body.
type TournamentRegistrationCreateRequest struct {
	Status TournamentRegistrationStatusType `json:"status" binding:"required"`
	Seed *int `json:"seed"`
	FinalStanding *int `json:"final_standing"`
	PointsEarned int `json:"points_earned"`
	RegisteredAt string `json:"registered_at" binding:"required"`
	TournamentID uint `json:"tournament_id"`
	PlayerID uint `json:"player_id"`
	DeckID uint `json:"deck_id"`
}

// TournamentRegistrationUpdateRequest is the PUT/PATCH body — all fields optional.
type TournamentRegistrationUpdateRequest struct {
	Status *TournamentRegistrationStatusType `json:"status"`
	Seed *int `json:"seed"`
	FinalStanding *int `json:"final_standing"`
	PointsEarned *int `json:"points_earned"`
	RegisteredAt *string `json:"registered_at"`
	TournamentID *uint `json:"tournament_id"`
	PlayerID *uint `json:"player_id"`
	DeckID *uint `json:"deck_id"`
}

// TournamentRegistrationResponse is the JSON representation returned by the API.
type TournamentRegistrationResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Status TournamentRegistrationStatusType `json:"status"`
	Seed *int `json:"seed"`
	FinalStanding *int `json:"final_standing"`
	PointsEarned int `json:"points_earned"`
	RegisteredAt string `json:"registered_at"`
	TournamentID uint `json:"tournament_id"`
	PlayerID uint `json:"player_id"`
	DeckID uint `json:"deck_id"`
}

type TournamentRegistration struct {
	gorm.Model
	Status TournamentRegistrationStatusType `gorm:"column:status;not null;default:'Registered'"`
	Seed *int `gorm:"column:seed"`
	FinalStanding *int `gorm:"column:final_standing"`
	PointsEarned int `gorm:"column:points_earned;not null;default:0"`
	RegisteredAt string `gorm:"column:registered_at;not null"`
	TournamentID uint `gorm:"column:tournament_id"`
	PlayerID uint `gorm:"column:player_id"`
	DeckID uint `gorm:"column:deck_id"`
}

func (m *TournamentRegistration) ToResponse() TournamentRegistrationResponse {
	return TournamentRegistrationResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Status: m.Status,
		Seed: m.Seed,
		FinalStanding: m.FinalStanding,
		PointsEarned: m.PointsEarned,
		RegisteredAt: m.RegisteredAt,
		TournamentID: m.TournamentID,
		PlayerID: m.PlayerID,
		DeckID: m.DeckID,
	}
}

func (m *TournamentRegistration) ApplyUpdate(req TournamentRegistrationUpdateRequest) {
	if req.Status != nil { m.Status = *req.Status }
	if req.Seed != nil { m.Seed = req.Seed }
	if req.FinalStanding != nil { m.FinalStanding = req.FinalStanding }
	if req.PointsEarned != nil { m.PointsEarned = *req.PointsEarned }
	if req.RegisteredAt != nil { m.RegisteredAt = *req.RegisteredAt }
	if req.TournamentID != nil { m.TournamentID = *req.TournamentID }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
	if req.DeckID != nil { m.DeckID = *req.DeckID }
}

func (m *TournamentRegistration) Withdraw()  error {
	return fmt.Errorf("Withdraw: not implemented")
}

func (m *TournamentRegistration) Disqualify(reason string)  error {
	return fmt.Errorf("Disqualify: not implemented")
}

func (m *TournamentRegistration) PromoteFromWaitlist()  error {
	return fmt.Errorf("PromoteFromWaitlist: not implemented")
}
