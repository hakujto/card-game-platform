package handler_players_test

import (
	"encoding/json"
	"net/http/httptest"
	"bytes"
	"testing"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)
func createDepPlayer(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepAchievement(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepCraftingRecipe(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"dust_cost": 1, "is_available": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/crafting_recipes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}
