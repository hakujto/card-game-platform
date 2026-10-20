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

func setupDeckTagApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewDeckTagHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postDeckTag(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_tags", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDeckTag(t *testing.T) {
	_, app := setupDeckTagApp(t)
	req := httptest.NewRequest("GET", "/api/deck_tags", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchDeckTag(t *testing.T) {
	_, app := setupDeckTagApp(t)
	req := httptest.NewRequest("GET", "/api/deck_tags?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDeckTag(t *testing.T) {
	_, app := setupDeckTagApp(t)
	body := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_tags", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
}

func TestGetDeckTag(t *testing.T) {
	db, app := setupDeckTagApp(t)
	created := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/deck_tags/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateDeckTag(t *testing.T) {
	db, app := setupDeckTagApp(t)
	created := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PATCH", fmt.Sprintf("/api/deck_tags/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteDeckTag(t *testing.T) {
	db, app := setupDeckTagApp(t)
	created := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/deck_tags/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
