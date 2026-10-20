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

func setupTournamentApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Role"); v != "" {
			c.Locals("user_role", v)
		}
		return c.Next()
	})
	h := handler_app.NewTournamentHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewSeasonHandler(db).RegisterRoutes(app)
	return db, app
}

func postTournament(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListTournament(t *testing.T) {
	_, app := setupTournamentApp(t)
	req := httptest.NewRequest("GET", "/api/tournaments", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchTournament(t *testing.T) {
	_, app := setupTournamentApp(t)
	req := httptest.NewRequest("GET", "/api/tournaments?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateTournament(t *testing.T) {
	db, app := setupTournamentApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	_ = depSeasonResp
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Tournament Alpha", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["public_id"])
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["format"])
	assert.NotNil(t, result["tournament_type"])
	assert.NotNil(t, result["max_players"])
	assert.NotNil(t, result["entry_fee"])
	assert.NotNil(t, result["prize_pool"])
	assert.NotNil(t, result["start_time"])
	assert.NotNil(t, result["end_time"])
	assert.NotNil(t, result["is_online"])
}

func TestGetTournament(t *testing.T) {
	db, app := setupTournamentApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	created := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Tournament Alpha", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/tournaments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateTournament(t *testing.T) {
	db, app := setupTournamentApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	created := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Tournament Alpha", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/tournaments/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
