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

func setupFriendshipApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Id"); v != "" {
			var uid uint
			fmt.Sscan(v, &uid)
			c.Locals("user_id", uid)
		}
		return c.Next()
	})
	h := handler_app.NewFriendshipHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewPlayerHandler(db).RegisterRoutes(app)
	return db, app
}

func postFriendship(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/friendships", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListFriendship(t *testing.T) {
	_, app := setupFriendshipApp(t)
	req := httptest.NewRequest("GET", "/api/friendships", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateFriendship(t *testing.T) {
	db, app := setupFriendshipApp(t)
	depPlayerResp := postPlayer(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	_ = depPlayerResp
	depPlayerID := uint(depPlayerResp["id"].(float64))
	_ = depPlayerID
	body := map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayerID, "receiver_id": depPlayerID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/friendships", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["status"])
}

func TestGetFriendship(t *testing.T) {
	db, app := setupFriendshipApp(t)
	depPlayerResp := postPlayer(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	depPlayerID := uint(depPlayerResp["id"].(float64))
	_ = depPlayerID
	created := postFriendship(t, app, db, map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayerID, "receiver_id": depPlayerID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/friendships/%v", id), nil)
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteFriendship(t *testing.T) {
	db, app := setupFriendshipApp(t)
	depPlayerResp := postPlayer(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	depPlayerID := uint(depPlayerResp["id"].(float64))
	_ = depPlayerID
	created := postFriendship(t, app, db, map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayerID, "receiver_id": depPlayerID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/friendships/%v", id), nil)
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
