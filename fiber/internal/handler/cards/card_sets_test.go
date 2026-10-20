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

func setupCardSetApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewCardSetHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postCardSet(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCardSet(t *testing.T) {
	_, app := setupCardSetApp(t)
	req := httptest.NewRequest("GET", "/api/card_sets", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchCardSet(t *testing.T) {
	_, app := setupCardSetApp(t)
	req := httptest.NewRequest("GET", "/api/card_sets?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCardSet(t *testing.T) {
	_, app := setupCardSetApp(t)
	body := map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "rotation_date": "2024-01-02", "set_type": "Core", "total_cards": 1, "is_rotated": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["code"])
	assert.NotNil(t, result["release_date"])
	assert.NotNil(t, result["rotation_date"])
	assert.NotNil(t, result["set_type"])
	assert.NotNil(t, result["total_cards"])
	assert.NotNil(t, result["is_rotated"])
}

func TestGetCardSet(t *testing.T) {
	db, app := setupCardSetApp(t)
	created := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "rotation_date": "2024-01-02", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/card_sets/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateCardSet(t *testing.T) {
	db, app := setupCardSetApp(t)
	created := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "rotation_date": "2024-01-02", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/card_sets/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
