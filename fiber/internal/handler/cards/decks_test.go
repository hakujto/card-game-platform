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

func setupDeckApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewDeckHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postDeck(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/decks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDeck(t *testing.T) {
	_, app := setupDeckApp(t)
	req := httptest.NewRequest("GET", "/api/decks", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchDeck(t *testing.T) {
	_, app := setupDeckApp(t)
	req := httptest.NewRequest("GET", "/api/decks?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDeck(t *testing.T) {
	_, app := setupDeckApp(t)
	body := map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/decks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["format"])
	assert.NotNil(t, result["is_public"])
	assert.NotNil(t, result["is_tournament_legal"])
	assert.NotNil(t, result["wins"])
	assert.NotNil(t, result["losses"])
	assert.NotNil(t, result["draws"])
}

func TestGetDeck(t *testing.T) {
	db, app := setupDeckApp(t)
	created := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/decks/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateDeck(t *testing.T) {
	db, app := setupDeckApp(t)
	created := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/decks/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteDeck(t *testing.T) {
	db, app := setupDeckApp(t)
	created := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/decks/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
