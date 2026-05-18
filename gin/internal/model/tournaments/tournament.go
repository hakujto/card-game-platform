package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type TournamentFormatType string
const (
	TournamentFormatType_Standard TournamentFormatType = "Standard"
	TournamentFormatType_Extended TournamentFormatType = "Extended"
	TournamentFormatType_Legacy TournamentFormatType = "Legacy"
	TournamentFormatType_Vintage TournamentFormatType = "Vintage"
	TournamentFormatType_Commander TournamentFormatType = "Commander"
	TournamentFormatType_Draft TournamentFormatType = "Draft"
)

type TournamentTournamentTypeType string
const (
	TournamentTournamentTypeType_Swiss TournamentTournamentTypeType = "Swiss"
	TournamentTournamentTypeType_SingleElimination TournamentTournamentTypeType = "SingleElimination"
	TournamentTournamentTypeType_DoubleElimination TournamentTournamentTypeType = "DoubleElimination"
	TournamentTournamentTypeType_RoundRobin TournamentTournamentTypeType = "RoundRobin"
)

type TournamentStatusType string
const (
	TournamentStatusType_Draft TournamentStatusType = "Draft"
	TournamentStatusType_Registration TournamentStatusType = "Registration"
	TournamentStatusType_Ongoing TournamentStatusType = "Ongoing"
	TournamentStatusType_Completed TournamentStatusType = "Completed"
	TournamentStatusType_Cancelled TournamentStatusType = "Cancelled"
)

// TournamentCreateRequest is the POST body.
type TournamentCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Description *string `json:"description"`
	Format TournamentFormatType `json:"format" binding:"required"`
	TournamentType TournamentTournamentTypeType `json:"tournament_type" binding:"required"`
	Status TournamentStatusType `json:"status" binding:"required"`
	MaxPlayers int `json:"max_players"`
	EntryFee types.Decimal `json:"entry_fee"`
	PrizePool types.Decimal `json:"prize_pool"`
	StartTime string `json:"start_time" binding:"required"`
	EndTime *string `json:"end_time"`
	IsOnline bool `json:"is_online"`
	Location *string `json:"location"`
	RulesText *string `json:"rules_text"`
	SeasonID uint `json:"season_id"`
	OrganizerID uint `json:"organizer_id"`
}

// TournamentUpdateRequest is the PUT/PATCH body — all fields optional.
type TournamentUpdateRequest struct {
	Name *string `json:"name"`
	Description *string `json:"description"`
	Format *TournamentFormatType `json:"format"`
	TournamentType *TournamentTournamentTypeType `json:"tournament_type"`
	Status *TournamentStatusType `json:"status"`
	MaxPlayers *int `json:"max_players"`
	EntryFee *types.Decimal `json:"entry_fee"`
	PrizePool *types.Decimal `json:"prize_pool"`
	StartTime *string `json:"start_time"`
	EndTime *string `json:"end_time"`
	IsOnline *bool `json:"is_online"`
	Location *string `json:"location"`
	RulesText *string `json:"rules_text"`
	SeasonID *uint `json:"season_id"`
	OrganizerID *uint `json:"organizer_id"`
}

// TournamentResponse is the JSON representation returned by the API.
type TournamentResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Description *string `json:"description"`
	Format TournamentFormatType `json:"format"`
	TournamentType TournamentTournamentTypeType `json:"tournament_type"`
	Status TournamentStatusType `json:"status"`
	MaxPlayers int `json:"max_players"`
	EntryFee types.Decimal `json:"entry_fee"`
	PrizePool types.Decimal `json:"prize_pool"`
	StartTime string `json:"start_time"`
	EndTime *string `json:"end_time"`
	IsOnline bool `json:"is_online"`
	Location *string `json:"location"`
	RulesText *string `json:"rules_text"`
	SeasonID uint `json:"season_id"`
	OrganizerID uint `json:"organizer_id"`
}

type Tournament struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Description *string `gorm:"column:description;type:text"`
	Format TournamentFormatType `gorm:"column:format;not null;default:'Standard'"`
	TournamentType TournamentTournamentTypeType `gorm:"column:tournament_type;not null;default:'Swiss'"`
	Status TournamentStatusType `gorm:"column:status;not null;default:'Draft'"`
	MaxPlayers int `gorm:"column:max_players;not null"`
	EntryFee types.Decimal `gorm:"column:entry_fee;type:decimal(10,2);not null;default:0"`
	PrizePool types.Decimal `gorm:"column:prize_pool;type:decimal(10,2);not null;default:0"`
	StartTime string `gorm:"column:start_time;not null"`
	EndTime *string `gorm:"column:end_time"`
	IsOnline bool `gorm:"column:is_online;default:true"`
	Location *string `gorm:"column:location"`
	RulesText *string `gorm:"column:rules_text;type:text"`
	SeasonID uint `gorm:"column:season_id"`
	OrganizerID uint `gorm:"column:organizer_id"`
	JudgesIDs []uint `gorm:"serializer:json;column:judges_ids"`
}

func (m *Tournament) ToResponse() TournamentResponse {
	return TournamentResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Description: m.Description,
		Format: m.Format,
		TournamentType: m.TournamentType,
		Status: m.Status,
		MaxPlayers: m.MaxPlayers,
		EntryFee: m.EntryFee,
		PrizePool: m.PrizePool,
		StartTime: m.StartTime,
		EndTime: m.EndTime,
		IsOnline: m.IsOnline,
		Location: m.Location,
		RulesText: m.RulesText,
		SeasonID: m.SeasonID,
		OrganizerID: m.OrganizerID,
	}
}

func (m *Tournament) ApplyUpdate(req TournamentUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Description != nil { m.Description = req.Description }
	if req.Format != nil { m.Format = *req.Format }
	if req.TournamentType != nil { m.TournamentType = *req.TournamentType }
	if req.Status != nil { m.Status = *req.Status }
	if req.MaxPlayers != nil { m.MaxPlayers = *req.MaxPlayers }
	if req.EntryFee != nil { m.EntryFee = *req.EntryFee }
	if req.PrizePool != nil { m.PrizePool = *req.PrizePool }
	if req.StartTime != nil { m.StartTime = *req.StartTime }
	if req.EndTime != nil { m.EndTime = req.EndTime }
	if req.IsOnline != nil { m.IsOnline = *req.IsOnline }
	if req.Location != nil { m.Location = req.Location }
	if req.RulesText != nil { m.RulesText = req.RulesText }
	if req.SeasonID != nil { m.SeasonID = *req.SeasonID }
	if req.OrganizerID != nil { m.OrganizerID = *req.OrganizerID }
}

func (m *Tournament) Start()  error {
	return fmt.Errorf("Start: not implemented")
}

func (m *Tournament) Cancel()  error {
	return fmt.Errorf("Cancel: not implemented")
}

func (m *Tournament) Complete()  error {
	return fmt.Errorf("Complete: not implemented")
}

func (m *Tournament) GenerateRound()  error {
	return fmt.Errorf("GenerateRound: not implemented")
}

func (m *Tournament) CalculatePrizeDistribution()  (float64, error) {
	return 0.0, fmt.Errorf("CalculatePrizeDistribution: not implemented")
}

func (m *Tournament) RegisterPlayer(playerId int, deckId int)  error {
	return fmt.Errorf("RegisterPlayer: not implemented")
}

func (m *Tournament) IsFull()  (bool, error) {
	return false, fmt.Errorf("IsFull: not implemented")
}
