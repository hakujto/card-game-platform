package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DraftPickCreateRequest is the POST body.
type DraftPickCreateRequest struct {
	PickNumber int `json:"pick_number"`
	PackNumber int `json:"pack_number"`
	PickedAt string `json:"picked_at" binding:"required"`
	ParticipantID uint `json:"participant_id"`
	CardID uint `json:"card_id"`
}

// DraftPickUpdateRequest is the PUT/PATCH body — all fields optional.
type DraftPickUpdateRequest struct {
	PickNumber *int `json:"pick_number"`
	PackNumber *int `json:"pack_number"`
	PickedAt *string `json:"picked_at"`
	ParticipantID *uint `json:"participant_id"`
	CardID *uint `json:"card_id"`
}

// DraftPickResponse is the JSON representation returned by the API.
type DraftPickResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	PickNumber int `json:"pick_number"`
	PackNumber int `json:"pack_number"`
	PickedAt string `json:"picked_at"`
	ParticipantID uint `json:"participant_id"`
	CardID uint `json:"card_id"`
}

type DraftPick struct {
	gorm.Model
	PickNumber int `gorm:"column:pick_number;not null"`
	PackNumber int `gorm:"column:pack_number;not null"`
	PickedAt string `gorm:"column:picked_at;not null"`
	ParticipantID uint `gorm:"column:participant_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *DraftPick) ToResponse() DraftPickResponse {
	return DraftPickResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		PickNumber: m.PickNumber,
		PackNumber: m.PackNumber,
		PickedAt: m.PickedAt,
		ParticipantID: m.ParticipantID,
		CardID: m.CardID,
	}
}

func (m *DraftPick) ApplyUpdate(req DraftPickUpdateRequest) {
	if req.PickNumber != nil { m.PickNumber = *req.PickNumber }
	if req.PackNumber != nil { m.PackNumber = *req.PackNumber }
	if req.PickedAt != nil { m.PickedAt = *req.PickedAt }
	if req.ParticipantID != nil { m.ParticipantID = *req.ParticipantID }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *DraftPick) IsFirstPick()  (bool, error) {
	return false, fmt.Errorf("IsFirstPick: not implemented")
}
