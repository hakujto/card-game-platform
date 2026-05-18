package model_tournaments

import (
	"time"

	"gorm.io/gorm"
)

type TournamentJudgeRoleType string
const (
	TournamentJudgeRoleType_HeadJudge TournamentJudgeRoleType = "HeadJudge"
	TournamentJudgeRoleType_Judge TournamentJudgeRoleType = "Judge"
	TournamentJudgeRoleType_ScorekeeperJudge TournamentJudgeRoleType = "ScorekeeperJudge"
)

// TournamentJudgeCreateRequest is the POST body.
type TournamentJudgeCreateRequest struct {
	Role TournamentJudgeRoleType `json:"role" binding:"required"`
	TournamentID uint `json:"tournament_id"`
	PlayerID uint `json:"player_id"`
}

// TournamentJudgeUpdateRequest is the PUT/PATCH body — all fields optional.
type TournamentJudgeUpdateRequest struct {
	Role *TournamentJudgeRoleType `json:"role"`
	TournamentID *uint `json:"tournament_id"`
	PlayerID *uint `json:"player_id"`
}

// TournamentJudgeResponse is the JSON representation returned by the API.
type TournamentJudgeResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Role TournamentJudgeRoleType `json:"role"`
	TournamentID uint `json:"tournament_id"`
	PlayerID uint `json:"player_id"`
}

type TournamentJudge struct {
	gorm.Model
	Role TournamentJudgeRoleType `gorm:"column:role;not null;default:'Judge'"`
	TournamentID uint `gorm:"column:tournament_id"`
	PlayerID uint `gorm:"column:player_id"`
}

func (m *TournamentJudge) ToResponse() TournamentJudgeResponse {
	return TournamentJudgeResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Role: m.Role,
		TournamentID: m.TournamentID,
		PlayerID: m.PlayerID,
	}
}

func (m *TournamentJudge) ApplyUpdate(req TournamentJudgeUpdateRequest) {
	if req.Role != nil { m.Role = *req.Role }
	if req.TournamentID != nil { m.TournamentID = *req.TournamentID }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
}
