package model_cards

import (
	"time"

	"gorm.io/gorm"
)

// DeckTagAssignmentCreateRequest is the POST body.
type DeckTagAssignmentCreateRequest struct {
	DeckID uint `json:"deck_id"`
	TagID uint `json:"tag_id"`
}

// DeckTagAssignmentUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckTagAssignmentUpdateRequest struct {
	DeckID *uint `json:"deck_id"`
	TagID *uint `json:"tag_id"`
}

// DeckTagAssignmentResponse is the JSON representation returned by the API.
type DeckTagAssignmentResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	DeckID uint `json:"deck_id"`
	TagID uint `json:"tag_id"`
}

type DeckTagAssignment struct {
	gorm.Model
	DeckID uint `gorm:"column:deck_id"`
	TagID uint `gorm:"column:tag_id"`
}

func (m *DeckTagAssignment) ToResponse() DeckTagAssignmentResponse {
	return DeckTagAssignmentResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		DeckID: m.DeckID,
		TagID: m.TagID,
	}
}

func (m *DeckTagAssignment) ApplyUpdate(req DeckTagAssignmentUpdateRequest) {
	if req.DeckID != nil { m.DeckID = *req.DeckID }
	if req.TagID != nil { m.TagID = *req.TagID }
}
