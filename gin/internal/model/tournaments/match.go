package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type MatchStatusType string
const (
	MatchStatusType_Pending MatchStatusType = "Pending"
	MatchStatusType_Active MatchStatusType = "Active"
	MatchStatusType_Completed MatchStatusType = "Completed"
	MatchStatusType_BYE MatchStatusType = "BYE"
	MatchStatusType_Draw MatchStatusType = "Draw"
)

// MatchCreateRequest is the POST body.
type MatchCreateRequest struct {
	TableNumber *int `json:"table_number"`
	Status MatchStatusType `json:"status" binding:"required"`
	Player1Wins int `json:"player1_wins"`
	Player2Wins int `json:"player2_wins"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	ResultNotes *string `json:"result_notes"`
	RoundID uint `json:"round_id"`
	Player1ID uint `json:"player1_id"`
	Player2ID *uint `json:"player2_id"`
}

// MatchUpdateRequest is the PUT/PATCH body — all fields optional.
type MatchUpdateRequest struct {
	TableNumber *int `json:"table_number"`
	Status *MatchStatusType `json:"status"`
	Player1Wins *int `json:"player1_wins"`
	Player2Wins *int `json:"player2_wins"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	ResultNotes *string `json:"result_notes"`
	RoundID *uint `json:"round_id"`
	Player1ID *uint `json:"player1_id"`
	Player2ID *uint `json:"player2_id"`
}

// MatchResponse is the JSON representation returned by the API.
type MatchResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	TableNumber *int `json:"table_number"`
	Status MatchStatusType `json:"status"`
	Player1Wins int `json:"player1_wins"`
	Player2Wins int `json:"player2_wins"`
	StartedAt *string `json:"started_at"`
	EndedAt *string `json:"ended_at"`
	ResultNotes *string `json:"result_notes"`
	RoundID uint `json:"round_id"`
	Player1ID uint `json:"player1_id"`
	Player2ID *uint `json:"player2_id"`
}

type Match struct {
	gorm.Model
	TableNumber *int `gorm:"column:table_number"`
	Status MatchStatusType `gorm:"column:status;not null;default:'Pending'"`
	Player1Wins int `gorm:"column:player1_wins;not null;default:0"`
	Player2Wins int `gorm:"column:player2_wins;not null;default:0"`
	StartedAt *string `gorm:"column:started_at"`
	EndedAt *string `gorm:"column:ended_at"`
	ResultNotes *string `gorm:"column:result_notes;type:text"`
	RoundID uint `gorm:"column:round_id"`
	Player1ID uint `gorm:"column:player1_id"`
	Player2ID *uint `gorm:"column:player2_id"`
}

func (m *Match) ToResponse() MatchResponse {
	return MatchResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		TableNumber: m.TableNumber,
		Status: m.Status,
		Player1Wins: m.Player1Wins,
		Player2Wins: m.Player2Wins,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		ResultNotes: m.ResultNotes,
		RoundID: m.RoundID,
		Player1ID: m.Player1ID,
		Player2ID: m.Player2ID,
	}
}

func (m *Match) ApplyUpdate(req MatchUpdateRequest) {
	if req.TableNumber != nil { m.TableNumber = req.TableNumber }
	if req.Status != nil { m.Status = *req.Status }
	if req.Player1Wins != nil { m.Player1Wins = *req.Player1Wins }
	if req.Player2Wins != nil { m.Player2Wins = *req.Player2Wins }
	if req.StartedAt != nil { m.StartedAt = req.StartedAt }
	if req.EndedAt != nil { m.EndedAt = req.EndedAt }
	if req.ResultNotes != nil { m.ResultNotes = req.ResultNotes }
	if req.RoundID != nil { m.RoundID = *req.RoundID }
	if req.Player1ID != nil { m.Player1ID = *req.Player1ID }
	if req.Player2ID != nil { m.Player2ID = req.Player2ID }
}

func (m *Match) RecordResult(p1Wins int, p2Wins int)  error {
	return fmt.Errorf("RecordResult: not implemented")
}

func (m *Match) DetermineWinner()  (bool, error) {
	return false, fmt.Errorf("DetermineWinner: not implemented")
}

func (m *Match) Draw()  error {
	return fmt.Errorf("Draw: not implemented")
}
