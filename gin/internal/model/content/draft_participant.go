package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DraftParticipantCreateRequest is the POST body.
type DraftParticipantCreateRequest struct {
	SeatNumber int `json:"seat_number"`
	JoinedAt string `json:"joined_at" binding:"required"`
	SessionID uint `json:"session_id"`
	PlayerID uint `json:"player_id"`
}

// DraftParticipantUpdateRequest is the PUT/PATCH body — all fields optional.
type DraftParticipantUpdateRequest struct {
	SeatNumber *int `json:"seat_number"`
	JoinedAt *string `json:"joined_at"`
	SessionID *uint `json:"session_id"`
	PlayerID *uint `json:"player_id"`
}

// DraftParticipantResponse is the JSON representation returned by the API.
type DraftParticipantResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	SeatNumber int `json:"seat_number"`
	JoinedAt string `json:"joined_at"`
	SessionID uint `json:"session_id"`
	PlayerID uint `json:"player_id"`
}

type DraftParticipant struct {
	gorm.Model
	SeatNumber int `gorm:"column:seat_number;not null"`
	JoinedAt string `gorm:"column:joined_at;not null"`
	SessionID uint `gorm:"column:session_id"`
	PlayerID uint `gorm:"column:player_id"`
}

func (m *DraftParticipant) ToResponse() DraftParticipantResponse {
	return DraftParticipantResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		SeatNumber: m.SeatNumber,
		JoinedAt: m.JoinedAt,
		SessionID: m.SessionID,
		PlayerID: m.PlayerID,
	}
}

func (m *DraftParticipant) ApplyUpdate(req DraftParticipantUpdateRequest) {
	if req.SeatNumber != nil { m.SeatNumber = *req.SeatNumber }
	if req.JoinedAt != nil { m.JoinedAt = *req.JoinedAt }
	if req.SessionID != nil { m.SessionID = *req.SessionID }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
}

func (m *DraftParticipant) PickCard(cardId int, packNumber int)  error {
	return fmt.Errorf("PickCard: not implemented")
}

func (m *DraftParticipant) DraftedCardCount()  (int, error) {
	return 0, fmt.Errorf("DraftedCardCount: not implemented")
}
