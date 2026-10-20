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

func setupTournamentRegistrationApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Id"); v != "" {
			var uid uint
			fmt.Sscan(v, &uid)
			c.Locals("user_id", uid)
		}
		return c.Next()
	})
	h := handler_app.NewTournamentRegistrationHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewSeasonHandler(db).RegisterRoutes(app)
	handler_app.NewTournamentHandler(db).RegisterRoutes(app)
	return db, app
}

func postTournamentRegistration(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListTournamentRegistration(t *testing.T) {
	_, app := setupTournamentRegistrationApp(t)
	req := httptest.NewRequest("GET", "/api/tournament_registrations", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateTournamentRegistration(t *testing.T) {
	db, app := setupTournamentRegistrationApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	_ = depSeasonResp
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	depTournamentResp := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	_ = depTournamentResp
	depTournamentID := uint(depTournamentResp["id"].(float64))
	_ = depTournamentID
	body := map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournamentID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["seed"])
	assert.NotNil(t, result["final_standing"])
	assert.NotNil(t, result["points_earned"])
	assert.NotNil(t, result["registered_at"])
}

func TestGetTournamentRegistration(t *testing.T) {
	db, app := setupTournamentRegistrationApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	depTournamentResp := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	depTournamentID := uint(depTournamentResp["id"].(float64))
	_ = depTournamentID
	created := postTournamentRegistration(t, app, db, map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournamentID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/tournament_registrations/%v", id), nil)
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
