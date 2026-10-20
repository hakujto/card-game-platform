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

func setupDeckTagAssignmentApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewDeckTagAssignmentHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewDeckHandler(db).RegisterRoutes(app)
	handler_app.NewDeckTagHandler(db).RegisterRoutes(app)
	return db, app
}

func postDeckTagAssignment(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDeckTagAssignment(t *testing.T) {
	_, app := setupDeckTagAssignmentApp(t)
	req := httptest.NewRequest("GET", "/api/deck_tag_assignments", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDeckTagAssignment(t *testing.T) {
	db, app := setupDeckTagAssignmentApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	_ = depDeckResp
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depDeckTagResp := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	_ = depDeckTagResp
	depDeckTagID := uint(depDeckTagResp["id"].(float64))
	_ = depDeckTagID
	body := map[string]interface{}{"deck_id": depDeckID, "tag_id": depDeckTagID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/deck_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
}

func TestGetDeckTagAssignment(t *testing.T) {
	db, app := setupDeckTagAssignmentApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depDeckTagResp := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	depDeckTagID := uint(depDeckTagResp["id"].(float64))
	_ = depDeckTagID
	created := postDeckTagAssignment(t, app, db, map[string]interface{}{"deck_id": depDeckID, "tag_id": depDeckTagID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/deck_tag_assignments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteDeckTagAssignment(t *testing.T) {
	db, app := setupDeckTagAssignmentApp(t)
	depDeckResp := postDeck(t, app, db, map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depDeckID := uint(depDeckResp["id"].(float64))
	_ = depDeckID
	depDeckTagResp := postDeckTag(t, app, db, map[string]interface{}{"name": "test"})
	depDeckTagID := uint(depDeckTagResp["id"].(float64))
	_ = depDeckTagID
	created := postDeckTagAssignment(t, app, db, map[string]interface{}{"deck_id": depDeckID, "tag_id": depDeckTagID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/deck_tag_assignments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
