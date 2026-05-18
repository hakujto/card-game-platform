package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type FriendshipStatusType string
const (
	FriendshipStatusType_Pending FriendshipStatusType = "Pending"
	FriendshipStatusType_Accepted FriendshipStatusType = "Accepted"
	FriendshipStatusType_Blocked FriendshipStatusType = "Blocked"
)

// FriendshipCreateRequest is the POST body.
type FriendshipCreateRequest struct {
	Status FriendshipStatusType `json:"status" binding:"required"`
	RequesterID uint `json:"requester_id"`
	ReceiverID uint `json:"receiver_id"`
}

// FriendshipUpdateRequest is the PUT/PATCH body — all fields optional.
type FriendshipUpdateRequest struct {
	Status *FriendshipStatusType `json:"status"`
	RequesterID *uint `json:"requester_id"`
	ReceiverID *uint `json:"receiver_id"`
}

// FriendshipResponse is the JSON representation returned by the API.
type FriendshipResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Status FriendshipStatusType `json:"status"`
	RequesterID uint `json:"requester_id"`
	ReceiverID uint `json:"receiver_id"`
}

type Friendship struct {
	gorm.Model
	Status FriendshipStatusType `gorm:"column:status;not null;default:'Pending'"`
	RequesterID uint `gorm:"column:requester_id"`
	ReceiverID uint `gorm:"column:receiver_id"`
}

func (m *Friendship) ToResponse() FriendshipResponse {
	return FriendshipResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Status: m.Status,
		RequesterID: m.RequesterID,
		ReceiverID: m.ReceiverID,
	}
}

func (m *Friendship) ApplyUpdate(req FriendshipUpdateRequest) {
	if req.Status != nil { m.Status = *req.Status }
	if req.RequesterID != nil { m.RequesterID = *req.RequesterID }
	if req.ReceiverID != nil { m.ReceiverID = *req.ReceiverID }
}

func (m *Friendship) Accept()  error {
	return fmt.Errorf("Accept: not implemented")
}

func (m *Friendship) Decline()  error {
	return fmt.Errorf("Decline: not implemented")
}

func (m *Friendship) Block()  error {
	return fmt.Errorf("Block: not implemented")
}
