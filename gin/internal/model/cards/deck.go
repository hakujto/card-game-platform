package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type DeckFormatType string
const (
	DeckFormatType_Standard DeckFormatType = "Standard"
	DeckFormatType_Extended DeckFormatType = "Extended"
	DeckFormatType_Legacy DeckFormatType = "Legacy"
	DeckFormatType_Vintage DeckFormatType = "Vintage"
	DeckFormatType_Commander DeckFormatType = "Commander"
	DeckFormatType_Draft DeckFormatType = "Draft"
)

type DeckArchetypeType string
const (
	DeckArchetypeType_Aggro DeckArchetypeType = "Aggro"
	DeckArchetypeType_Control DeckArchetypeType = "Control"
	DeckArchetypeType_Midrange DeckArchetypeType = "Midrange"
	DeckArchetypeType_Combo DeckArchetypeType = "Combo"
	DeckArchetypeType_Prison DeckArchetypeType = "Prison"
	DeckArchetypeType_Tempo DeckArchetypeType = "Tempo"
)

// DeckCreateRequest is the POST body.
type DeckCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Description *string `json:"description"`
	Format DeckFormatType `json:"format" binding:"required"`
	IsPublic bool `json:"is_public"`
	IsTournamentLegal bool `json:"is_tournament_legal"`
	Archetype *DeckArchetypeType `json:"archetype"`
	Wins int `json:"wins"`
	Losses int `json:"losses"`
	Draws int `json:"draws"`
	PlayerID uint `json:"player_id"`
}

// DeckUpdateRequest is the PUT/PATCH body — all fields optional.
type DeckUpdateRequest struct {
	Name *string `json:"name"`
	Description *string `json:"description"`
	Format *DeckFormatType `json:"format"`
	IsPublic *bool `json:"is_public"`
	IsTournamentLegal *bool `json:"is_tournament_legal"`
	Archetype *DeckArchetypeType `json:"archetype"`
	Wins *int `json:"wins"`
	Losses *int `json:"losses"`
	Draws *int `json:"draws"`
	PlayerID *uint `json:"player_id"`
}

// DeckResponse is the JSON representation returned by the API.
type DeckResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Description *string `json:"description"`
	Format DeckFormatType `json:"format"`
	IsPublic bool `json:"is_public"`
	IsTournamentLegal bool `json:"is_tournament_legal"`
	Archetype *DeckArchetypeType `json:"archetype"`
	Wins int `json:"wins"`
	Losses int `json:"losses"`
	Draws int `json:"draws"`
	PlayerID uint `json:"player_id"`
}

type Deck struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Description *string `gorm:"column:description;type:text"`
	Format DeckFormatType `gorm:"column:format;not null;default:'Standard'"`
	IsPublic bool `gorm:"column:is_public;default:false"`
	IsTournamentLegal bool `gorm:"column:is_tournament_legal;default:false"`
	Archetype *DeckArchetypeType `gorm:"column:archetype"`
	Wins int `gorm:"column:wins;not null;default:0"`
	Losses int `gorm:"column:losses;not null;default:0"`
	Draws int `gorm:"column:draws;not null;default:0"`
	PlayerID uint `gorm:"column:player_id"`
	CardsIDs []uint `gorm:"serializer:json;column:cards_ids"`
	SideboardCardsIDs []uint `gorm:"serializer:json;column:sideboard_cards_ids"`
	TagsIDs []uint `gorm:"serializer:json;column:tags_ids"`
}

func (m *Deck) ToResponse() DeckResponse {
	return DeckResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Description: m.Description,
		Format: m.Format,
		IsPublic: m.IsPublic,
		IsTournamentLegal: m.IsTournamentLegal,
		Archetype: m.Archetype,
		Wins: m.Wins,
		Losses: m.Losses,
		Draws: m.Draws,
		PlayerID: m.PlayerID,
	}
}

func (m *Deck) ApplyUpdate(req DeckUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Description != nil { m.Description = req.Description }
	if req.Format != nil { m.Format = *req.Format }
	if req.IsPublic != nil { m.IsPublic = *req.IsPublic }
	if req.IsTournamentLegal != nil { m.IsTournamentLegal = *req.IsTournamentLegal }
	if req.Archetype != nil { m.Archetype = req.Archetype }
	if req.Wins != nil { m.Wins = *req.Wins }
	if req.Losses != nil { m.Losses = *req.Losses }
	if req.Draws != nil { m.Draws = *req.Draws }
	if req.PlayerID != nil { m.PlayerID = *req.PlayerID }
}

func (m *Deck) ValidateSize()  (bool, error) {
	return false, fmt.Errorf("ValidateSize: not implemented")
}

func (m *Deck) AddCard(cardId int, quantity int)  error {
	return fmt.Errorf("AddCard: not implemented")
}

func (m *Deck) RemoveCard(cardId int)  error {
	return fmt.Errorf("RemoveCard: not implemented")
}

func (m *Deck) WinRate()  (float64, error) {
	return 0.0, fmt.Errorf("WinRate: not implemented")
}

func (m *Deck) Clone()  (interface{}, error) {
	return nil, fmt.Errorf("Clone: not implemented")
}

func (m *Deck) Publish()  error {
	return fmt.Errorf("Publish: not implemented")
}

func (m *Deck) Unpublish()  error {
	return fmt.Errorf("Unpublish: not implemented")
}

func (m *Deck) CertifyTournamentLegal()  (bool, error) {
	return false, fmt.Errorf("CertifyTournamentLegal: not implemented")
}
