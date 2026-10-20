package handler_players_test

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

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupPlayerApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	app := fiber.New()
	h := handler_app.NewPlayerHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postPlayer(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListPlayer(t *testing.T) {
	_, app := setupPlayerApp(t)
	req := httptest.NewRequest("GET", "/api/players", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchPlayer(t *testing.T) {
	_, app := setupPlayerApp(t)
	req := httptest.NewRequest("GET", "/api/players?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreatePlayer(t *testing.T) {
	_, app := setupPlayerApp(t)
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["public_id"])
	assert.NotNil(t, result["display_name"])
	assert.NotNil(t, result["rank"])
	assert.NotNil(t, result["rating"])
	assert.NotNil(t, result["peak_rating"])
	assert.NotNil(t, result["is_verified"])
}

func TestGetPlayer(t *testing.T) {
	db, app := setupPlayerApp(t)
	created := postPlayer(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/players/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdatePlayer(t *testing.T) {
	db, app := setupPlayerApp(t)
	created := postPlayer(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PATCH", fmt.Sprintf("/api/players/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
