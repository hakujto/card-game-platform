package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// CardRulingCreateRequest is the POST body.
type CardRulingCreateRequest struct {
	RulingText string `json:"ruling_text" binding:"required"`
	PublishedAt string `json:"published_at" binding:"required"`
	Source string `json:"source" binding:"required"`
	CardID uint `json:"card_id"`
}

// CardRulingUpdateRequest is the PUT/PATCH body — all fields optional.
type CardRulingUpdateRequest struct {
	RulingText *string `json:"ruling_text"`
	PublishedAt *string `json:"published_at"`
	Source *string `json:"source"`
	CardID *uint `json:"card_id"`
}

// CardRulingResponse is the JSON representation returned by the API.
type CardRulingResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	RulingText string `json:"ruling_text"`
	PublishedAt string `json:"published_at"`
	Source string `json:"source"`
	CardID uint `json:"card_id"`
}

type CardRuling struct {
	gorm.Model
	RulingText string `gorm:"column:ruling_text;type:text;not null"`
	PublishedAt string `gorm:"column:published_at;not null"`
	Source string `gorm:"column:source;not null"`
	CardID uint `gorm:"column:card_id"`
}

func (m *CardRuling) ToResponse() CardRulingResponse {
	return CardRulingResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		RulingText: m.RulingText,
		PublishedAt: m.PublishedAt,
		Source: m.Source,
		CardID: m.CardID,
	}
}

func (m *CardRuling) ApplyUpdate(req CardRulingUpdateRequest) {
	if req.RulingText != nil { m.RulingText = *req.RulingText }
	if req.PublishedAt != nil { m.PublishedAt = *req.PublishedAt }
	if req.Source != nil { m.Source = *req.Source }
	if req.CardID != nil { m.CardID = *req.CardID }
}

func (m *CardRuling) IsCurrent()  (bool, error) {
	return false, fmt.Errorf("IsCurrent: not implemented")
}

func (m *CardRuling) SupersedesPrevious()  (bool, error) {
	return false, fmt.Errorf("SupersedesPrevious: not implemented")
}
