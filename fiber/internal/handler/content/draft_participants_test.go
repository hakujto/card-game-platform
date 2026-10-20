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

func setupDraftParticipantApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	app := fiber.New()
	h := handler_app.NewDraftParticipantHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewDraftSessionHandler(db).RegisterRoutes(app)
	return db, app
}

func postDraftParticipant(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_participants", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListDraftParticipant(t *testing.T) {
	_, app := setupDraftParticipantApp(t)
	req := httptest.NewRequest("GET", "/api/draft_participants", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateDraftParticipant(t *testing.T) {
	db, app := setupDraftParticipantApp(t)
	depDraftSessionResp := postDraftSession(t, app, db, map[string]interface{}{"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 1, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00Z"})
	_ = depDraftSessionResp
	depDraftSessionID := uint(depDraftSessionResp["id"].(float64))
	_ = depDraftSessionID
	body := map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSessionID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_participants", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["seat_number"])
	assert.NotNil(t, result["joined_at"])
}

func TestGetDraftParticipant(t *testing.T) {
	db, app := setupDraftParticipantApp(t)
	depDraftSessionResp := postDraftSession(t, app, db, map[string]interface{}{"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 1, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00Z"})
	depDraftSessionID := uint(depDraftSessionResp["id"].(float64))
	_ = depDraftSessionID
	created := postDraftParticipant(t, app, db, map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSessionID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/draft_participants/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
