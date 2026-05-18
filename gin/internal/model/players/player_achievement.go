package model_players

import (
	"time"

	"gorm.io/gorm"
)

// PlayerAchievementCreateRequest is the POST body.
type PlayerAchievementCreateRequest struct {
	EarnedAt string `json:"earned_at" binding:"required"`
	Progress int `json:"progress"`
	IsCompleted bool `json:"is_completed"`
	PlayerID uint `json:"player_id"`
	AchievementID uint `json:"achievement_id"`
}

// PlayerAchievementUpdateRequest is the PUT/PATCH body — all fields optional.
type PlayerAchievementUpdateRequest struct {
	EarnedAt *string `json:"earned_at"`
	Progress *int `json:"progress"`
	IsCompleted *bool `json:"is_completed"`
	PlayerID *uint `json:"player_id"`
	AchievementID *uint `json:"achievement_id"`
}

// PlayerAchievementResponse is the JSON representation returned by the API.
type PlayerAchievementResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	EarnedAt string `json:"earned_at"`
	Progress int `json:"progress"`
	IsCompleted bool `json:"is_completed"`
	PlayerID uint `json:"player_id"`
	AchievementID uint `json:"achievement_id"`
}

type PlayerAchievement struct {
	gorm.Model
	EarnedAt string `gorm:"column:earned_at;not null"`
	Progress int `gorm:"column:progress;not null;default:0"`
	IsCompleted bool `gorm:"column:is_completed;default:false"`
	PlayerID uint `gorm:"column:player_id"`
	AchievementID uint `gorm:"column:achievement_id"`
}

func (m *PlayerAchievement) ToResponse() PlayerAchievementResponse {
	return PlayerAchievementResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		EarnedAt: m.EarnedAt,
		Progress: m.Progress,
		IsCompleted: m.IsCompleted,
		PlayerID: m.PlayerID,
		AchievementID: m.AchievementID,
	}
}

func (m *PlayerAchievement) ApplyUpdate(req PlayerAchievementUpdateRequest) {
	if req.EarnedAt != nil { m.EarnedAt = *req.EarnedAt }
	if req.Progress != nil { m.Progress = *req.Progress }
	if req.IsCompleted != nil { m.IsCompleted = *req.IsCompleted }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
	if req.AchievementID != nil { m.AchievementID = *req.AchievementID }
}
