package handler_content_test

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

	handler_app "cards_project/internal/handler/content"
	model "cards_project/internal/model/content"
)

func setupStreamApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Role"); v != "" {
			c.Locals("user_role", v)
		}
		return c.Next()
	})
	h := handler_app.NewStreamHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postStream(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/streams", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListStream(t *testing.T) {
	_, app := setupStreamApp(t)
	req := httptest.NewRequest("GET", "/api/streams", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchStream(t *testing.T) {
	_, app := setupStreamApp(t)
	req := httptest.NewRequest("GET", "/api/streams?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateStream(t *testing.T) {
	_, app := setupStreamApp(t)
	body := map[string]interface{}{"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/streams", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["title"])
	assert.NotNil(t, result["stream_url"])
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["platform"])
	assert.NotNil(t, result["language"])
	assert.NotNil(t, result["is_official"])
	assert.NotNil(t, result["viewer_count_peak"])
	assert.NotNil(t, result["scheduled_start"])
}

func TestGetStream(t *testing.T) {
	db, app := setupStreamApp(t)
	created := postStream(t, app, db, map[string]interface{}{"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/streams/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateStream(t *testing.T) {
	db, app := setupStreamApp(t)
	created := postStream(t, app, db, map[string]interface{}{"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"title": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/streams/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
