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

func setupDeckCardApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewDeckCardHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewDeckHandler(db).RegisterRoutes(app)
	handler_app.NewCardSetHandler(db).RegisterRoutes(app)
	handler_app.NewCardHandler(db).RegisterRoutes(app)
	return db, app
}

func postDeckCard(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDeckCard(t *testing.T) {
	_, app := setupDeckCardApp(t)
	req := httptest.NewRequest("GET", "/api/deck_cards", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDeckCard(t *testing.T) {
	db, app := setupDeckCardApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	_ = depDeckResp
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	_ = depCardSetResp
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	_ = depCardResp
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	body := map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeckID, "card_id": depCardID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["quantity"])
	assert.NotNil(t, result["is_commander"])
}

func TestGetDeckCard(t *testing.T) {
	db, app := setupDeckCardApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	created := postDeckCard(t, app, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeckID, "card_id": depCardID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/deck_cards/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateDeckCard(t *testing.T) {
	db, app := setupDeckCardApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	created := postDeckCard(t, app, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeckID, "card_id": depCardID})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"quantity": 1}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PATCH", fmt.Sprintf("/api/deck_cards/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteDeckCard(t *testing.T) {
	db, app := setupDeckCardApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	created := postDeckCard(t, app, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeckID, "card_id": depCardID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/deck_cards/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
