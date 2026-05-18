package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// DeckTagCreateRequest is the POST body.
type DeckTagCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Color *string `json:"color"`
}

// DeckTagUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckTagUpdateRequest struct {
	Name *string `json:"name"`
	Color *string `json:"color"`
}

// DeckTagResponse is the JSON representation returned by the API.
type DeckTagResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Color *string `json:"color"`
}

type DeckTag struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Color *string `gorm:"column:color"`
}

func (m *DeckTag) ToResponse() DeckTagResponse {
	return DeckTagResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Color: m.Color,
	}
}

func (m *DeckTag) ApplyUpdate(req DeckTagUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Color != nil { m.Color = req.Color }
}

func (m *DeckTag) Rename(newName string)  error {
	return fmt.Errorf("Rename: not implemented")
}

func (m *DeckTag) MergeInto(targetTagId int)  error {
	return fmt.Errorf("MergeInto: not implemented")
}
