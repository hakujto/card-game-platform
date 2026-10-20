package handler_cards_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"bytes"
	"fmt"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/cards"
	model "cards_project/internal/model/cards"
)

func setupCardApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewCardHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewCardSetHandler(db).RegisterRoutes(app)
	return db, app
}

func postCard(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCard(t *testing.T) {
	_, app := setupCardApp(t)
	req := httptest.NewRequest("GET", "/api/cards", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchCard(t *testing.T) {
	_, app := setupCardApp(t)
	req := httptest.NewRequest("GET", "/api/cards?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCard(t *testing.T) {
	db, app := setupCardApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	_ = depCardSetResp
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Lightning Bolt", "card_type": "Spell", "rarity": "Common", "mana_cost": 0, "mana_colors": []interface{}{"White"}, "attack": 1, "defense": 1, "loyalty": nil, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": false, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["public_id"])
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["card_type"])
	assert.NotNil(t, result["rarity"])
	assert.NotNil(t, result["mana_cost"])
	assert.NotNil(t, result["mana_colors"])
	assert.NotNil(t, result["attack"])
	assert.NotNil(t, result["defense"])
	assert.NotNil(t, result["loyalty"])
	assert.NotNil(t, result["description"])
	assert.NotNil(t, result["legal_formats"])
	assert.NotNil(t, result["is_banned"])
	assert.NotNil(t, result["is_restricted"])
	assert.NotNil(t, result["power_level"])
	assert.NotNil(t, result["total_copies_in_circulation"])
}

func TestGetCard(t *testing.T) {
	db, app := setupCardApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	created := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Lightning Bolt", "card_type": "Spell", "rarity": "Common", "mana_cost": 0, "mana_colors": []interface{}{"White"}, "attack": 1, "defense": 1, "loyalty": nil, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": false, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/cards/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateCard(t *testing.T) {
	db, app := setupCardApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	created := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Lightning Bolt", "card_type": "Spell", "rarity": "Common", "mana_cost": 0, "mana_colors": []interface{}{"White"}, "attack": 1, "defense": 1, "loyalty": nil, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": false, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/cards/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
