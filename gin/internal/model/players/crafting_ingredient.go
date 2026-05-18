package model_players

import (
	"time"

	"gorm.io/gorm"
)

// CraftingIngredientCreateRequest is the POST body.
type CraftingIngredientCreateRequest struct {
	Quantity int `json:"quantity"`
	RecipeID uint `json:"recipe_id"`
	CardID uint `json:"card_id"`
}

// CraftingIngredientUpdateRequest is the PUT/PATCH body — all fields optional.
type CraftingIngredientUpdateRequest struct {
	Quantity *int `json:"quantity"`
	RecipeID *uint `json:"recipe_id"`
	CardID *uint `json:"card_id"`
}

// CraftingIngredientResponse is the JSON representation returned by the API.
type CraftingIngredientResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Quantity int `json:"quantity"`
	RecipeID uint `json:"recipe_id"`
	CardID uint `json:"card_id"`
}

type CraftingIngredient struct {
	gorm.Model
	Quantity int `gorm:"column:quantity;not null;default:1"`
	RecipeID uint `gorm:"column:recipe_id"`
	CardID uint `gorm:"column:card_id"`
}

func (m *CraftingIngredient) ToResponse() CraftingIngredientResponse {
	return CraftingIngredientResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Quantity: m.Quantity,
		RecipeID: m.RecipeID,
		CardID: m.CardID,
	}
}

func (m *CraftingIngredient) ApplyUpdate(req CraftingIngredientUpdateRequest) {
	if req.Quantity != nil { m.Quantity = *req.Quantity }
	if req.RecipeID != nil { m.RecipeID = *req.RecipeID }
	if req.CardID != nil { m.CardID = *req.CardID }
}
