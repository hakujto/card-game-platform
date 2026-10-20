package handler_cards_test

import (
	"encoding/json"
	"net/http/httptest"
	"bytes"
	"testing"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)
func createDepCardSet(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepCard(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepDeck(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/decks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepDeckTag(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_tags", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}
