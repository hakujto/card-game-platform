package handler_tournaments_test

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

	handler_app "cards_project/internal/handler/tournaments"
	model "cards_project/internal/model/tournaments"
)

func setupSeasonApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	app := fiber.New()
	h := handler_app.NewSeasonHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postSeason(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/seasons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListSeason(t *testing.T) {
	_, app := setupSeasonApp(t)
	req := httptest.NewRequest("GET", "/api/seasons", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchSeason(t *testing.T) {
	_, app := setupSeasonApp(t)
	req := httptest.NewRequest("GET", "/api/seasons?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateSeason(t *testing.T) {
	_, app := setupSeasonApp(t)
	body := map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/seasons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["start_date"])
	assert.NotNil(t, result["end_date"])
	assert.NotNil(t, result["format"])
	assert.NotNil(t, result["is_active"])
}

func TestGetSeason(t *testing.T) {
	db, app := setupSeasonApp(t)
	created := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/seasons/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateSeason(t *testing.T) {
	db, app := setupSeasonApp(t)
	created := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/seasons/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
