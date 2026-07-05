package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DeckTagCreateRequest is the POST body.
type DeckTagCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Slug *string `json:"slug"`
	Color *string `json:"color"`
}

// DeckTagUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckTagUpdateRequest struct {
	Name *string `json:"name"`
	Slug *string `json:"slug"`
	Color *string `json:"color"`
}

// DeckTagResponse is the JSON representation returned by the API.
type DeckTagResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Slug *string `json:"slug"`
	Color *string `json:"color"`
}

type DeckTag struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Slug *string `gorm:"column:slug"`
	Color *string `gorm:"column:color"`
	DeckAssignments []DeckTagAssignment `gorm:"foreignKey:TagID"`
}

func (m *DeckTag) ToResponse() DeckTagResponse {
	return DeckTagResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Slug: m.Slug,
		Color: m.Color,
	}
}

func (m *DeckTag) ApplyUpdate(req DeckTagUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Slug != nil { m.Slug = req.Slug }
	if req.Color != nil { m.Color = req.Color }
}

// ── Business operations ──────────────────────────────────────────

func (m *DeckTag) Rename(newName string)  error {
	return fmt.Errorf("Rename: not implemented")
}

func (m *DeckTag) MergeInto(targetTagId int)  error {
	return fmt.Errorf("MergeInto: not implemented")
}
