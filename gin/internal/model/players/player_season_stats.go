package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type PlayerSeasonStatsHighestRankType string
const (
	PlayerSeasonStatsHighestRankType_Bronze PlayerSeasonStatsHighestRankType = "Bronze"
	PlayerSeasonStatsHighestRankType_Silver PlayerSeasonStatsHighestRankType = "Silver"
	PlayerSeasonStatsHighestRankType_Gold PlayerSeasonStatsHighestRankType = "Gold"
	PlayerSeasonStatsHighestRankType_Platinum PlayerSeasonStatsHighestRankType = "Platinum"
	PlayerSeasonStatsHighestRankType_Diamond PlayerSeasonStatsHighestRankType = "Diamond"
	PlayerSeasonStatsHighestRankType_Master PlayerSeasonStatsHighestRankType = "Master"
	PlayerSeasonStatsHighestRankType_Grandmaster PlayerSeasonStatsHighestRankType = "Grandmaster"
)

// PlayerSeasonStatsCreateRequest is the POST body.
type PlayerSeasonStatsCreateRequest struct {
	Wins int `json:"wins"`
	Losses int `json:"losses"`
	Draws int `json:"draws"`
	TournamentWins int `json:"tournament_wins"`
	HighestRank *PlayerSeasonStatsHighestRankType `json:"highest_rank"`
	SeasonPoints int `json:"season_points"`
	PlayerID uint `json:"player_id"`
	SeasonID uint `json:"season_id"`
}

// PlayerSeasonStatsUpdateRequest is the PUT/PATCH body — all fields optional.
type PlayerSeasonStatsUpdateRequest struct {
	Wins *int `json:"wins"`
	Losses *int `json:"losses"`
	Draws *int `json:"draws"`
	TournamentWins *int `json:"tournament_wins"`
	HighestRank *PlayerSeasonStatsHighestRankType `json:"highest_rank"`
	SeasonPoints *int `json:"season_points"`
	PlayerID *uint `json:"player_id"`
	SeasonID *uint `json:"season_id"`
}

// PlayerSeasonStatsResponse is the JSON representation returned by the API.
type PlayerSeasonStatsResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Wins int `json:"wins"`
	Losses int `json:"losses"`
	Draws int `json:"draws"`
	TournamentWins int `json:"tournament_wins"`
	HighestRank *PlayerSeasonStatsHighestRankType `json:"highest_rank"`
	SeasonPoints int `json:"season_points"`
	PlayerID uint `json:"player_id"`
	SeasonID uint `json:"season_id"`
}

type PlayerSeasonStats struct {
	gorm.Model
	Wins int `gorm:"column:wins;not null;default:0"`
	Losses int `gorm:"column:losses;not null;default:0"`
	Draws int `gorm:"column:draws;not null;default:0"`
	TournamentWins int `gorm:"column:tournament_wins;not null;default:0"`
	HighestRank *PlayerSeasonStatsHighestRankType `gorm:"column:highest_rank"`
	SeasonPoints int `gorm:"column:season_points;not null;default:0"`
	PlayerID uint `gorm:"column:player_id"`
	SeasonID uint `gorm:"column:season_id"`
}

func (m *PlayerSeasonStats) ToResponse() PlayerSeasonStatsResponse {
	return PlayerSeasonStatsResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Wins: m.Wins,
		Losses: m.Losses,
		Draws: m.Draws,
		TournamentWins: m.TournamentWins,
		HighestRank: m.HighestRank,
		SeasonPoints: m.SeasonPoints,
		PlayerID: m.PlayerID,
		SeasonID: m.SeasonID,
	}
}

func (m *PlayerSeasonStats) ApplyUpdate(req PlayerSeasonStatsUpdateRequest) {
	if req.Wins != nil { m.Wins = *req.Wins }
	if req.Losses != nil { m.Losses = *req.Losses }
	if req.Draws != nil { m.Draws = *req.Draws }
	if req.TournamentWins != nil { m.TournamentWins = *req.TournamentWins }
	if req.HighestRank != nil { m.HighestRank = req.HighestRank }
	if req.SeasonPoints != nil { m.SeasonPoints = *req.SeasonPoints }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
	if req.SeasonID != nil { m.SeasonID = *req.SeasonID }
}

func (m *PlayerSeasonStats) WinRate()  (float64, error) {
	return 0.0, fmt.Errorf("WinRate: not implemented")
}

func (m *PlayerSeasonStats) AddPoints(points int)  error {
	return fmt.Errorf("AddPoints: not implemented")
}

func (m *PlayerSeasonStats) RecordTournamentWin()  error {
	return fmt.Errorf("RecordTournamentWin: not implemented")
}
