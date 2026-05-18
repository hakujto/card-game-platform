package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type GameWinnerSideType string
const (
	GameWinnerSideType_Player1 GameWinnerSideType = "Player1"
	GameWinnerSideType_Player2 GameWinnerSideType = "Player2"
	GameWinnerSideType_Draw GameWinnerSideType = "Draw"
)

type GameEndedByType string
const (
	GameEndedByType_Normal GameEndedByType = "Normal"
	GameEndedByType_Timeout GameEndedByType = "Timeout"
	GameEndedByType_Concession GameEndedByType = "Concession"
	GameEndedByType_DrawOffer GameEndedByType = "DrawOffer"
)

// GameCreateRequest is the POST body.
type GameCreateRequest struct {
	GameNumber int `json:"game_number"`
	WinnerSide *GameWinnerSideType `json:"winner_side"`
	TurnsPlayed *int `json:"turns_played"`
	DurationSeconds *int `json:"duration_seconds"`
	EndedBy *GameEndedByType `json:"ended_by"`
	ReplayUrl *string `json:"replay_url"`
	MatchID uint `json:"match_id"`
	WinnerID *uint `json:"winner_id"`
}

// GameUpdateRequest is the PUT/PATCH body — all fields optional.
type GameUpdateRequest struct {
	GameNumber *int `json:"game_number"`
	WinnerSide *GameWinnerSideType `json:"winner_side"`
	TurnsPlayed *int `json:"turns_played"`
	DurationSeconds *int `json:"duration_seconds"`
	EndedBy *GameEndedByType `json:"ended_by"`
	ReplayUrl *string `json:"replay_url"`
	MatchID *uint `json:"match_id"`
	WinnerID *uint `json:"winner_id"`
}

// GameResponse is the JSON representation returned by the API.
type GameResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	GameNumber int `json:"game_number"`
	WinnerSide *GameWinnerSideType `json:"winner_side"`
	TurnsPlayed *int `json:"turns_played"`
	DurationSeconds *int `json:"duration_seconds"`
	EndedBy *GameEndedByType `json:"ended_by"`
	ReplayUrl *string `json:"replay_url"`
	MatchID uint `json:"match_id"`
	WinnerID *uint `json:"winner_id"`
}

type Game struct {
	gorm.Model
	GameNumber int `gorm:"column:game_number;not null"`
	WinnerSide *GameWinnerSideType `gorm:"column:winner_side"`
	TurnsPlayed *int `gorm:"column:turns_played"`
	DurationSeconds *int `gorm:"column:duration_seconds"`
	EndedBy *GameEndedByType `gorm:"column:ended_by"`
	ReplayUrl *string `gorm:"column:replay_url"`
	MatchID uint `gorm:"column:match_id"`
	WinnerID *uint `gorm:"column:winner_id"`
}

func (m *Game) ToResponse() GameResponse {
	return GameResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		GameNumber: m.GameNumber,
		WinnerSide: m.WinnerSide,
		TurnsPlayed: m.TurnsPlayed,
		DurationSeconds: m.DurationSeconds,
		EndedBy: m.EndedBy,
		ReplayUrl: m.ReplayUrl,
		MatchID: m.MatchID,
		WinnerID: m.WinnerID,
	}
}

func (m *Game) ApplyUpdate(req GameUpdateRequest) {
	if req.GameNumber != nil { m.GameNumber = *req.GameNumber }
	if req.WinnerSide != nil { m.WinnerSide = req.WinnerSide }
	if req.TurnsPlayed != nil { m.TurnsPlayed = req.TurnsPlayed }
	if req.DurationSeconds != nil { m.DurationSeconds = req.DurationSeconds }
	if req.EndedBy != nil { m.EndedBy = req.EndedBy }
	if req.ReplayUrl != nil { m.ReplayUrl = req.ReplayUrl }
	if req.MatchID != nil { m.MatchID = *req.MatchID }
	if req.WinnerID != nil { m.WinnerID = req.WinnerID }
}

func (m *Game) RecordWinner(winnerSide string)  error {
	return fmt.Errorf("RecordWinner: not implemented")
}

func (m *Game) DurationMinutes()  (float64, error) {
	return 0.0, fmt.Errorf("DurationMinutes: not implemented")
}
