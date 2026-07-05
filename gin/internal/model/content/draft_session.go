package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
	"encoding/json"
)

var _ = json.RawMessage{}
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
	PackContents *json.RawMessage `json:"pack_contents"`
	Seats int `json:"seats"`
	TimePerPickSeconds int `json:"time_per_pick_seconds"`
	CompletedAt *string `json:"completed_at"`
	CardSetID uint `json:"card_set_id"`
}

// DraftSessionUpdateRequest is the PUT/PATCH body — all fields optional.
type DraftSessionUpdateRequest struct {
	Status *DraftSessionStatusType `json:"status"`
	DraftType *DraftSessionDraftTypeType `json:"draft_type"`
	PackContents *json.RawMessage `json:"pack_contents"`
	Seats *int `json:"seats"`
	TimePerPickSeconds *int `json:"time_per_pick_seconds"`
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
	PackContents *json.RawMessage `json:"pack_contents"`
	Seats int `json:"seats"`
	TimePerPickSeconds int `json:"time_per_pick_seconds"`
	CompletedAt *string `json:"completedAt"`
	CardSetID uint `json:"card_set_id"`
}

type DraftSession struct {
	gorm.Model
	Status DraftSessionStatusType `gorm:"column:status;not null;default:'WaitingForPlayers'"`
	DraftType DraftSessionDraftTypeType `gorm:"column:draft_type;not null;default:'Booster'"`
	PackContents *json.RawMessage `gorm:"column:pack_contents;type:text"`
	Seats int `gorm:"column:seats;not null;default:8"`
	TimePerPickSeconds int `gorm:"column:time_per_pick_seconds;not null;default:30"`
	CompletedAt *string `gorm:"column:completed_at"`
	CardSetID uint `gorm:"column:card_set_id;constraint:OnDelete:RESTRICT"`
	Participants []DraftParticipant `gorm:"foreignKey:SessionID"`
}

func (m *DraftSession) ToResponse() DraftSessionResponse {
	return DraftSessionResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Status: m.Status,
		DraftType: m.DraftType,
		PackContents: m.PackContents,
		Seats: m.Seats,
		TimePerPickSeconds: m.TimePerPickSeconds,
		CompletedAt: m.CompletedAt,
		CardSetID: m.CardSetID,
	}
}

func (m *DraftSession) ApplyUpdate(req DraftSessionUpdateRequest) {
	if req.Status != nil { m.Status = *req.Status }
	if req.DraftType != nil { m.DraftType = *req.DraftType }
	if req.PackContents != nil { m.PackContents = req.PackContents }
	if req.Seats != nil { m.Seats = *req.Seats }
	if req.TimePerPickSeconds != nil { m.TimePerPickSeconds = *req.TimePerPickSeconds }
	if req.CompletedAt != nil { m.CompletedAt = req.CompletedAt }
	if req.CardSetID != nil { m.CardSetID = *req.CardSetID }
}

// ── Lifecycle state machine ──────────────────────────────────────
var DraftSessionAllowedTransitions = map[string]map[string]bool{
		"WaitingForPlayers": {"Drafting": true, "Abandoned": true},
		"Drafting": {"Completed": true, "Abandoned": true},
}

func (m *DraftSession) AssertTransition(to string) error {
	current := string(m.Status)
	allowed, ok := DraftSessionAllowedTransitions[current]
	if !ok || !allowed[to] {
		return fmt.Errorf("transition %s -> %s is not allowed", current, to)
	}
	return nil
}

// ── Business operations ──────────────────────────────────────────

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
