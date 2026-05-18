package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type TradeDisputeReasonType string
const (
	TradeDisputeReasonType_ItemNotReceived TradeDisputeReasonType = "ItemNotReceived"
	TradeDisputeReasonType_ItemNotAsDescribed TradeDisputeReasonType = "ItemNotAsDescribed"
	TradeDisputeReasonType_FraudSuspected TradeDisputeReasonType = "FraudSuspected"
	TradeDisputeReasonType_Other TradeDisputeReasonType = "Other"
)

type TradeDisputeStatusType string
const (
	TradeDisputeStatusType_Open TradeDisputeStatusType = "Open"
	TradeDisputeStatusType_UnderReview TradeDisputeStatusType = "UnderReview"
	TradeDisputeStatusType_Resolved TradeDisputeStatusType = "Resolved"
	TradeDisputeStatusType_Escalated TradeDisputeStatusType = "Escalated"
)

// TradeDisputeCreateRequest is the POST body.
type TradeDisputeCreateRequest struct {
	Reason TradeDisputeReasonType `json:"reason" binding:"required"`
	Description string `json:"description" binding:"required"`
	Status TradeDisputeStatusType `json:"status" binding:"required"`
	Resolution *string `json:"resolution"`
	OpenedAt string `json:"opened_at" binding:"required"`
	ResolvedAt *string `json:"resolved_at"`
	TransactionID uint `json:"transaction_id"`
	OpenedByID uint `json:"opened_by_id"`
	ResolvedByID *uint `json:"resolved_by_id"`
}

// TradeDisputeUpdateRequest is the PUT/PATCH body — all fields optional.
type TradeDisputeUpdateRequest struct {
	Reason *TradeDisputeReasonType `json:"reason"`
	Description *string `json:"description"`
	Status *TradeDisputeStatusType `json:"status"`
	Resolution *string `json:"resolution"`
	OpenedAt *string `json:"opened_at"`
	ResolvedAt *string `json:"resolved_at"`
	TransactionID *uint `json:"transaction_id"`
	OpenedByID *uint `json:"opened_by_id"`
	ResolvedByID *uint `json:"resolved_by_id"`
}

// TradeDisputeResponse is the JSON representation returned by the API.
type TradeDisputeResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Reason TradeDisputeReasonType `json:"reason"`
	Description string `json:"description"`
	Status TradeDisputeStatusType `json:"status"`
	Resolution *string `json:"resolution"`
	OpenedAt string `json:"opened_at"`
	ResolvedAt *string `json:"resolved_at"`
	TransactionID uint `json:"transaction_id"`
	OpenedByID uint `json:"opened_by_id"`
	ResolvedByID *uint `json:"resolved_by_id"`
}

type TradeDispute struct {
	gorm.Model
	Reason TradeDisputeReasonType `gorm:"column:reason;not null"`
	Description string `gorm:"column:description;type:text;not null"`
	Status TradeDisputeStatusType `gorm:"column:status;not null;default:'Open'"`
	Resolution *string `gorm:"column:resolution;type:text"`
	OpenedAt string `gorm:"column:opened_at;not null"`
	ResolvedAt *string `gorm:"column:resolved_at"`
	TransactionID uint `gorm:"column:transaction_id"`
	OpenedByID uint `gorm:"column:opened_by_id"`
	ResolvedByID *uint `gorm:"column:resolved_by_id"`
}

func (m *TradeDispute) ToResponse() TradeDisputeResponse {
	return TradeDisputeResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Reason: m.Reason,
		Description: m.Description,
		Status: m.Status,
		Resolution: m.Resolution,
		OpenedAt: m.OpenedAt,
		ResolvedAt: m.ResolvedAt,
		TransactionID: m.TransactionID,
		OpenedByID: m.OpenedByID,
		ResolvedByID: m.ResolvedByID,
	}
}

func (m *TradeDispute) ApplyUpdate(req TradeDisputeUpdateRequest) {
	if req.Reason != nil { m.Reason = *req.Reason }
	if req.Description != nil { m.Description = *req.Description }
	if req.Status != nil { m.Status = *req.Status }
	if req.Resolution != nil { m.Resolution = req.Resolution }
	if req.OpenedAt != nil { m.OpenedAt = *req.OpenedAt }
	if req.ResolvedAt != nil { m.ResolvedAt = req.ResolvedAt }
	if req.TransactionID != nil { m.TransactionID = *req.TransactionID }
	if req.OpenedByID != nil { m.OpenedByID = *req.OpenedByID }
	if req.ResolvedByID != nil { m.ResolvedByID = req.ResolvedByID }
}

func (m *TradeDispute) Escalate()  error {
	return fmt.Errorf("Escalate: not implemented")
}

func (m *TradeDispute) Resolve(resolutionText string)  error {
	return fmt.Errorf("Resolve: not implemented")
}

func (m *TradeDispute) Review()  error {
	return fmt.Errorf("Review: not implemented")
}
