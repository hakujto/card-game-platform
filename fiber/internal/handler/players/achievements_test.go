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

func setupAchievementApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	app := fiber.New()
	h := handler_app.NewAchievementHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postAchievement(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListAchievement(t *testing.T) {
	_, app := setupAchievementApp(t)
	req := httptest.NewRequest("GET", "/api/achievements", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchAchievement(t *testing.T) {
	_, app := setupAchievementApp(t)
	req := httptest.NewRequest("GET", "/api/achievements?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateAchievement(t *testing.T) {
	_, app := setupAchievementApp(t)
	body := map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["description"])
	assert.NotNil(t, result["points"])
	assert.NotNil(t, result["rarity"])
	assert.NotNil(t, result["is_hidden"])
}

func TestGetAchievement(t *testing.T) {
	db, app := setupAchievementApp(t)
	created := postAchievement(t, app, db, map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/achievements/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateAchievement(t *testing.T) {
	db, app := setupAchievementApp(t)
	created := postAchievement(t, app, db, map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/achievements/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
