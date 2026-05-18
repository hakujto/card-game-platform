package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type DraftSessionStatusType string
const (
	DraftSessionStatusType_WaitingForPlayers DraftSessionStatusType = "WaitingForPlayers"
	DraftSessionStatusType_Drafting DraftSessionStatusType = "Drafting"
	DraftSessionStatusType_Completed DraftSessionStatusType = "Completed"
	DraftSessionStatusType_Abandoned DraftSessionStatusType = "Abandoned"
)

type DraftSessionDraftTypeType string
const (
	DraftSessionDraftTypeType_Booster DraftSessionDraftTypeType = "Booster"
	DraftSessionDraftTypeType_Cube DraftSessionDraftTypeType = "Cube"
	DraftSessionDraftTypeType_Rochester DraftSessionDraftTypeType = "Rochester"
)

// DraftSessionCreateRequest is the POST body.
type DraftSessionCreateRequest struct {
	Status DraftSessionStatusType `json:"status" binding:"required"`
	DraftType DraftSessionDraftTypeType `json:"draft_type" binding:"required"`
	Seats int `json:"seats"`
	CompletedAt *string `json:"completed_at"`
	CardSetID uint `json:"card_set_id"`
}

// DraftSessionUpdateRequest is the PUT/PATCH body — all fields optional.
type DraftSessionUpdateRequest struct {
	Status *DraftSessionStatusType `json:"status"`
	DraftType *DraftSessionDraftTypeType `json:"draft_type"`
	Seats *int `json:"seats"`
	CompletedAt *string `json:"completed_at"`
	CardSetID *uint `json:"card_set_id"`
}

// DraftSessionResponse is the JSON representation returned by the API.
type DraftSessionResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Status DraftSessionStatusType `json:"status"`
	DraftType DraftSessionDraftTypeType `json:"draft_type"`
	Seats int `json:"seats"`
	CompletedAt *string `json:"completed_at"`
	CardSetID uint `json:"card_set_id"`
}

type DraftSession struct {
	gorm.Model
	Status DraftSessionStatusType `gorm:"column:status;not null;default:'WaitingForPlayers'"`
	DraftType DraftSessionDraftTypeType `gorm:"column:draft_type;not null;default:'Booster'"`
	Seats int `gorm:"column:seats;not null;default:8"`
	CompletedAt *string `gorm:"column:completed_at"`
	CardSetID uint `gorm:"column:card_set_id"`
}

func (m *DraftSession) ToResponse() DraftSessionResponse {
	return DraftSessionResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Status: m.Status,
		DraftType: m.DraftType,
		Seats: m.Seats,
		CompletedAt: m.CompletedAt,
		CardSetID: m.CardSetID,
	}
}

func (m *DraftSession) ApplyUpdate(req DraftSessionUpdateRequest) {
	if req.Status != nil { m.Status = *req.Status }
	if req.DraftType != nil { m.DraftType = *req.DraftType }
	if req.Seats != nil { m.Seats = *req.Seats }
	if req.CompletedAt != nil { m.CompletedAt = req.CompletedAt }
	if req.CardSetID != nil { m.CardSetID = *req.CardSetID }
}

func (m *DraftSession) Start()  error {
	return fmt.Errorf("Start: not implemented")
}

func (m *DraftSession) Abandon()  error {
	return fmt.Errorf("Abandon: not implemented")
}

func (m *DraftSession) Complete()  error {
	return fmt.Errorf("Complete: not implemented")
}

func (m *DraftSession) IsFull()  (bool, error) {
	return false, fmt.Errorf("IsFull: not implemented")
}
