package model_tournaments

import (
	"time"

	"gorm.io/gorm"
)

// AwardedPrizeCreateRequest is the POST body.
type AwardedPrizeCreateRequest struct {
	FinalPlacement int `json:"final_placement"`
	AwardedAt string `json:"awarded_at" binding:"required"`
	Claimed bool `json:"claimed"`
	ClaimedAt *string `json:"claimed_at"`
	PrizeID uint `json:"prize_id"`
	PlayerID uint `json:"player_id"`
}

// AwardedPrizeUpdateRequest is the PUT/PATCH body — all fields optional.
type AwardedPrizeUpdateRequest struct {
	FinalPlacement *int `json:"final_placement"`
	AwardedAt *string `json:"awarded_at"`
	Claimed *bool `json:"claimed"`
	ClaimedAt *string `json:"claimed_at"`
	PrizeID *uint `json:"prize_id"`
	PlayerID *uint `json:"player_id"`
}

// AwardedPrizeResponse is the JSON representation returned by the API.
type AwardedPrizeResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	FinalPlacement int `json:"final_placement"`
	AwardedAt string `json:"awarded_at"`
	Claimed bool `json:"claimed"`
	ClaimedAt *string `json:"claimed_at"`
	PrizeID uint `json:"prize_id"`
	PlayerID uint `json:"player_id"`
}

type AwardedPrize struct {
	gorm.Model
	FinalPlacement int `gorm:"column:final_placement;not null"`
	AwardedAt string `gorm:"column:awarded_at;not null"`
	Claimed bool `gorm:"column:claimed;default:false"`
	ClaimedAt *string `gorm:"column:claimed_at"`
	PrizeID uint `gorm:"column:prize_id"`
	PlayerID uint `gorm:"column:player_id"`
}

func (m *AwardedPrize) ToResponse() AwardedPrizeResponse {
	return AwardedPrizeResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		FinalPlacement: m.FinalPlacement,
		AwardedAt: m.AwardedAt,
		Claimed: m.Claimed,
		ClaimedAt: m.ClaimedAt,
		PrizeID: m.PrizeID,
		PlayerID: m.PlayerID,
	}
}

func (m *AwardedPrize) ApplyUpdate(req AwardedPrizeUpdateRequest) {
	if req.FinalPlacement != nil { m.FinalPlacement = *req.FinalPlacement }
	if req.AwardedAt != nil { m.AwardedAt = *req.AwardedAt }
	if req.Claimed != nil { m.Claimed = *req.Claimed }
	if req.ClaimedAt != nil { m.ClaimedAt = req.ClaimedAt }
	if req.PrizeID != nil { m.PrizeID = *req.PrizeID }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
}
