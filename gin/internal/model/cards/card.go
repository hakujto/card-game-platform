package model_cards

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type CardCardTypeType string
const (
	CardCardTypeType_Creature CardCardTypeType = "Creature"
	CardCardTypeType_Spell CardCardTypeType = "Spell"
	CardCardTypeType_Land CardCardTypeType = "Land"
	CardCardTypeType_Artifact CardCardTypeType = "Artifact"
	CardCardTypeType_Enchantment CardCardTypeType = "Enchantment"
	CardCardTypeType_Planeswalker CardCardTypeType = "Planeswalker"
)

type CardRarityType string
const (
	CardRarityType_Common CardRarityType = "Common"
	CardRarityType_Uncommon CardRarityType = "Uncommon"
	CardRarityType_Rare CardRarityType = "Rare"
	CardRarityType_MythicRare CardRarityType = "MythicRare"
	CardRarityType_Legendary CardRarityType = "Legendary"
)

type CardManaColorsType string
const (
	CardManaColorsType_White CardManaColorsType = "White"
	CardManaColorsType_Blue CardManaColorsType = "Blue"
	CardManaColorsType_Black CardManaColorsType = "Black"
	CardManaColorsType_Red CardManaColorsType = "Red"
	CardManaColorsType_Green CardManaColorsType = "Green"
	CardManaColorsType_Colorless CardManaColorsType = "Colorless"
)

type CardLegalFormatsType string
const (
	CardLegalFormatsType_Standard CardLegalFormatsType = "Standard"
	CardLegalFormatsType_Extended CardLegalFormatsType = "Extended"
	CardLegalFormatsType_Legacy CardLegalFormatsType = "Legacy"
	CardLegalFormatsType_Vintage CardLegalFormatsType = "Vintage"
	CardLegalFormatsType_Commander CardLegalFormatsType = "Commander"
	CardLegalFormatsType_Draft CardLegalFormatsType = "Draft"
)

// CardCreateRequest is the POST body.
type CardCreateRequest struct {
	Name string `json:"name" binding:"required"`
	CardType CardCardTypeType `json:"card_type" binding:"required"`
	Rarity CardRarityType `json:"rarity" binding:"required"`
	ManaCost int `json:"mana_cost"`
	ManaColors CardManaColorsType `json:"mana_colors" binding:"required"`
	Attack *int `json:"attack"`
	Defense *int `json:"defense"`
	Loyalty *int `json:"loyalty"`
	Description string `json:"description" binding:"required"`
	FlavorText *string `json:"flavor_text"`
	ImageUrl *string `json:"image_url"`
	ArtistName *string `json:"artist_name"`
	LegalFormats CardLegalFormatsType `json:"legal_formats" binding:"required"`
	IsBanned bool `json:"is_banned"`
	IsRestricted bool `json:"is_restricted"`
	PowerLevel int `json:"power_level"`
	SetID uint `json:"set_id"`
}

// CardUpdateRequest is the PUT/PATCH body — all fields optional.
type CardUpdateRequest struct {
	Name *string `json:"name"`
	CardType *CardCardTypeType `json:"card_type"`
	Rarity *CardRarityType `json:"rarity"`
	ManaCost *int `json:"mana_cost"`
	ManaColors *CardManaColorsType `json:"mana_colors"`
	Attack *int `json:"attack"`
	Defense *int `json:"defense"`
	Loyalty *int `json:"loyalty"`
	Description *string `json:"description"`
	FlavorText *string `json:"flavor_text"`
	ImageUrl *string `json:"image_url"`
	ArtistName *string `json:"artist_name"`
	LegalFormats *CardLegalFormatsType `json:"legal_formats"`
	IsBanned *bool `json:"is_banned"`
	IsRestricted *bool `json:"is_restricted"`
	PowerLevel *int `json:"power_level"`
	SetID *uint `json:"set_id"`
}

// CardResponse is the JSON representation returned by the API.
type CardResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	CardType CardCardTypeType `json:"card_type"`
	Rarity CardRarityType `json:"rarity"`
	ManaCost int `json:"mana_cost"`
	ManaColors CardManaColorsType `json:"mana_colors"`
	Attack *int `json:"attack"`
	Defense *int `json:"defense"`
	Loyalty *int `json:"loyalty"`
	Description string `json:"description"`
	FlavorText *string `json:"flavor_text"`
	ImageUrl *string `json:"image_url"`
	ArtistName *string `json:"artist_name"`
	LegalFormats CardLegalFormatsType `json:"legal_formats"`
	IsBanned bool `json:"is_banned"`
	IsRestricted bool `json:"is_restricted"`
	PowerLevel int `json:"power_level"`
	SetID uint `json:"set_id"`
}

type Card struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	CardType CardCardTypeType `gorm:"column:card_type;not null;default:'Creature'"`
	Rarity CardRarityType `gorm:"column:rarity;not null;default:'Common'"`
	ManaCost int `gorm:"column:mana_cost;not null;default:0"`
	ManaColors CardManaColorsType `gorm:"column:mana_colors;not null"`
	Attack *int `gorm:"column:attack"`
	Defense *int `gorm:"column:defense"`
	Loyalty *int `gorm:"column:loyalty"`
	Description string `gorm:"column:description;type:text;not null"`
	FlavorText *string `gorm:"column:flavor_text;type:text"`
	ImageUrl *string `gorm:"column:image_url"`
	ArtistName *string `gorm:"column:artist_name"`
	LegalFormats CardLegalFormatsType `gorm:"column:legal_formats;not null"`
	IsBanned bool `gorm:"column:is_banned;default:false"`
	IsRestricted bool `gorm:"column:is_restricted;default:false"`
	PowerLevel int `gorm:"column:power_level;not null;default:1"`
	SetID uint `gorm:"column:set_id"`
}

func (m *Card) ToResponse() CardResponse {
	return CardResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		CardType: m.CardType,
		Rarity: m.Rarity,
		ManaCost: m.ManaCost,
		ManaColors: m.ManaColors,
		Attack: m.Attack,
		Defense: m.Defense,
		Loyalty: m.Loyalty,
		Description: m.Description,
		FlavorText: m.FlavorText,
		ImageUrl: m.ImageUrl,
		ArtistName: m.ArtistName,
		LegalFormats: m.LegalFormats,
		IsBanned: m.IsBanned,
		IsRestricted: m.IsRestricted,
		PowerLevel: m.PowerLevel,
		SetID: m.SetID,
	}
}

func (m *Card) ApplyUpdate(req CardUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.CardType != nil { m.CardType = *req.CardType }
	if req.Rarity != nil { m.Rarity = *req.Rarity }
	if req.ManaCost != nil { m.ManaCost = *req.ManaCost }
	if req.ManaColors != nil { m.ManaColors = *req.ManaColors }
	if req.Attack != nil { m.Attack = req.Attack }
	if req.Defense != nil { m.Defense = req.Defense }
	if req.Loyalty != nil { m.Loyalty = req.Loyalty }
	if req.Description != nil { m.Description = *req.Description }
	if req.FlavorText != nil { m.FlavorText = req.FlavorText }
	if req.ImageUrl != nil { m.ImageUrl = req.ImageUrl }
	if req.ArtistName != nil { m.ArtistName = req.ArtistName }
	if req.LegalFormats != nil { m.LegalFormats = *req.LegalFormats }
	if req.IsBanned != nil { m.IsBanned = *req.IsBanned }
	if req.IsRestricted != nil { m.IsRestricted = *req.IsRestricted }
	if req.PowerLevel != nil { m.PowerLevel = *req.PowerLevel }
	if req.SetID != nil { m.SetID = *req.SetID }
}

func (m *Card) Ban()  error {
	return fmt.Errorf("Ban: not implemented")
}

func (m *Card) Unban()  error {
	return fmt.Errorf("Unban: not implemented")
}

func (m *Card) Restrict()  error {
	return fmt.Errorf("Restrict: not implemented")
}

func (m *Card) Unrestrict()  error {
	return fmt.Errorf("Unrestrict: not implemented")
}

func (m *Card) CalculateValue()  (float64, error) {
	return 0.0, fmt.Errorf("CalculateValue: not implemented")
}

func (m *Card) ApplyRarityBonus(multiplier int)  (float64, error) {
	return 0.0, fmt.Errorf("ApplyRarityBonus: not implemented")
}

func (m *Card) IsLegalInFormat(format string)  (bool, error) {
	return false, fmt.Errorf("IsLegalInFormat: not implemented")
}
