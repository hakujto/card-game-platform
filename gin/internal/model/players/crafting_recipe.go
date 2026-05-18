package model_players

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// CraftingRecipeCreateRequest is the POST body.
type CraftingRecipeCreateRequest struct {
	DustCost int `json:"dust_cost"`
	IsAvailable bool `json:"is_available"`
	ResultCardID uint `json:"result_card_id"`
}

// CraftingRecipeUpdateRequest is the PUT/PATCH body — all fields optional.
type CraftingRecipeUpdateRequest struct {
	DustCost *int `json:"dust_cost"`
	IsAvailable *bool `json:"is_available"`
	ResultCardID *uint `json:"result_card_id"`
}

// CraftingRecipeResponse is the JSON representation returned by the API.
type CraftingRecipeResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	DustCost int `json:"dust_cost"`
	IsAvailable bool `json:"is_available"`
	ResultCardID uint `json:"result_card_id"`
}

type CraftingRecipe struct {
	gorm.Model
	DustCost int `gorm:"column:dust_cost;not null"`
	IsAvailable bool `gorm:"column:is_available;default:true"`
	ResultCardID uint `gorm:"column:result_card_id"`
	RequiredCardsIDs []uint `gorm:"serializer:json;column:required_cards_ids"`
}

func (m *CraftingRecipe) ToResponse() CraftingRecipeResponse {
	return CraftingRecipeResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		DustCost: m.DustCost,
		IsAvailable: m.IsAvailable,
		ResultCardID: m.ResultCardID,
	}
}

func (m *CraftingRecipe) ApplyUpdate(req CraftingRecipeUpdateRequest) {
	if req.DustCost != nil { m.DustCost = *req.DustCost }
	if req.IsAvailable != nil { m.IsAvailable = *req.IsAvailable }
	if req.ResultCardID != nil { m.ResultCardID = *req.ResultCardID }
}

func (m *CraftingRecipe) CanCraft(playerId int)  (bool, error) {
	return false, fmt.Errorf("CanCraft: not implemented")
}

func (m *CraftingRecipe) ExecuteCraft(playerId int)  error {
	return fmt.Errorf("ExecuteCraft: not implemented")
}

func (m *CraftingRecipe) Disable()  error {
	return fmt.Errorf("Disable: not implemented")
}

func (m *CraftingRecipe) Enable()  error {
	return fmt.Errorf("Enable: not implemented")
}
