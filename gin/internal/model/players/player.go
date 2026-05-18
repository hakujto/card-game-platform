package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type PlayerRankType string
const (
	PlayerRankType_Bronze PlayerRankType = "Bronze"
	PlayerRankType_Silver PlayerRankType = "Silver"
	PlayerRankType_Gold PlayerRankType = "Gold"
	PlayerRankType_Platinum PlayerRankType = "Platinum"
	PlayerRankType_Diamond PlayerRankType = "Diamond"
	PlayerRankType_Master PlayerRankType = "Master"
	PlayerRankType_Grandmaster PlayerRankType = "Grandmaster"
)

type PlayerPreferredFormatType string
const (
	PlayerPreferredFormatType_Standard PlayerPreferredFormatType = "Standard"
	PlayerPreferredFormatType_Extended PlayerPreferredFormatType = "Extended"
	PlayerPreferredFormatType_Legacy PlayerPreferredFormatType = "Legacy"
	PlayerPreferredFormatType_Vintage PlayerPreferredFormatType = "Vintage"
	PlayerPreferredFormatType_Commander PlayerPreferredFormatType = "Commander"
	PlayerPreferredFormatType_Draft PlayerPreferredFormatType = "Draft"
)

// PlayerCreateRequest is the POST body.
type PlayerCreateRequest struct {
	DisplayName string `json:"display_name" binding:"required"`
	Rank PlayerRankType `json:"rank" binding:"required"`
	Rating int `json:"rating"`
	PeakRating int `json:"peak_rating"`
	Bio *string `json:"bio"`
	CountryCode *string `json:"country_code"`
	AvatarUrl *string `json:"avatar_url"`
	PreferredFormat *PlayerPreferredFormatType `json:"preferred_format"`
	IsVerified bool `json:"is_verified"`
	LastActiveAt *string `json:"last_active_at"`
	UserID uint `json:"user_id"`
}

// PlayerUpdateRequest is the PUT/PATCH body — all fields optional.
type PlayerUpdateRequest struct {
	DisplayName *string `json:"display_name"`
	Rank *PlayerRankType `json:"rank"`
	Rating *int `json:"rating"`
	PeakRating *int `json:"peak_rating"`
	Bio *string `json:"bio"`
	CountryCode *string `json:"country_code"`
	AvatarUrl *string `json:"avatar_url"`
	PreferredFormat *PlayerPreferredFormatType `json:"preferred_format"`
	IsVerified *bool `json:"is_verified"`
	LastActiveAt *string `json:"last_active_at"`
	UserID *uint `json:"user_id"`
}

// PlayerResponse is the JSON representation returned by the API.
type PlayerResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	DisplayName string `json:"display_name"`
	Rank PlayerRankType `json:"rank"`
	Rating int `json:"rating"`
	PeakRating int `json:"peak_rating"`
	Bio *string `json:"bio"`
	CountryCode *string `json:"country_code"`
	AvatarUrl *string `json:"avatar_url"`
	PreferredFormat *PlayerPreferredFormatType `json:"preferred_format"`
	IsVerified bool `json:"is_verified"`
	LastActiveAt *string `json:"last_active_at"`
	UserID uint `json:"user_id"`
}

type Player struct {
	gorm.Model
	DisplayName string `gorm:"column:display_name;not null"`
	Rank PlayerRankType `gorm:"column:rank;not null;default:'Bronze'"`
	Rating int `gorm:"column:rating;not null;default:1000"`
	PeakRating int `gorm:"column:peak_rating;not null;default:1000"`
	Bio *string `gorm:"column:bio;type:text"`
	CountryCode *string `gorm:"column:country_code"`
	AvatarUrl *string `gorm:"column:avatar_url"`
	PreferredFormat *PlayerPreferredFormatType `gorm:"column:preferred_format"`
	IsVerified bool `gorm:"column:is_verified;default:false"`
	LastActiveAt *string `gorm:"column:last_active_at"`
	UserID uint `gorm:"column:user_id"`
	AchievementsIDs []uint `gorm:"serializer:json;column:achievements_ids"`
	FriendsIDs []uint `gorm:"serializer:json;column:friends_ids"`
}

func (m *Player) ToResponse() PlayerResponse {
	return PlayerResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		DisplayName: m.DisplayName,
		Rank: m.Rank,
		Rating: m.Rating,
		PeakRating: m.PeakRating,
		Bio: m.Bio,
		CountryCode: m.CountryCode,
		AvatarUrl: m.AvatarUrl,
		PreferredFormat: m.PreferredFormat,
		IsVerified: m.IsVerified,
		LastActiveAt: m.LastActiveAt,
		UserID: m.UserID,
	}
}

func (m *Player) ApplyUpdate(req PlayerUpdateRequest) {
	if req.DisplayName != nil { m.DisplayName = *req.DisplayName }
	if req.Rank != nil { m.Rank = *req.Rank }
	if req.Rating != nil { m.Rating = *req.Rating }
	if req.PeakRating != nil { m.PeakRating = *req.PeakRating }
	if req.Bio != nil { m.Bio = req.Bio }
	if req.CountryCode != nil { m.CountryCode = req.CountryCode }
	if req.AvatarUrl != nil { m.AvatarUrl = req.AvatarUrl }
	if req.PreferredFormat != nil { m.PreferredFormat = req.PreferredFormat }
	if req.IsVerified != nil { m.IsVerified = *req.IsVerified }
	if req.LastActiveAt != nil { m.LastActiveAt = req.LastActiveAt }
	if req.UserID != nil { m.UserID = *req.UserID }
}

func (m *Player) Promote()  (bool, error) {
	return false, fmt.Errorf("Promote: not implemented")
}

func (m *Player) Demote()  (bool, error) {
	return false, fmt.Errorf("Demote: not implemented")
}

func (m *Player) RecordWin()  error {
	return fmt.Errorf("RecordWin: not implemented")
}

func (m *Player) RecordLoss()  error {
	return fmt.Errorf("RecordLoss: not implemented")
}

func (m *Player) WinRate()  (float64, error) {
	return 0.0, fmt.Errorf("WinRate: not implemented")
}

func (m *Player) Verify()  error {
	return fmt.Errorf("Verify: not implemented")
}

func (m *Player) UpdateRating(delta int)  error {
	return fmt.Errorf("UpdateRating: not implemented")
}
