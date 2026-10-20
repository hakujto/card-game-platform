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

func setupDraftSessionApp(t *testing.T) (*gorm.DB, *fiber.App) {
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
	h := handler_app.NewDraftSessionHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postDraftSession(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_sessions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDraftSession(t *testing.T) {
	_, app := setupDraftSessionApp(t)
	req := httptest.NewRequest("GET", "/api/draft_sessions", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDraftSession(t *testing.T) {
	_, app := setupDraftSessionApp(t)
	body := map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_sessions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["draft_type"])
	assert.NotNil(t, result["seats"])
	assert.NotNil(t, result["time_per_pick_seconds"])
}

func TestGetDraftSession(t *testing.T) {
	db, app := setupDraftSessionApp(t)
	created := postDraftSession(t, app, db, map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/draft_sessions/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
