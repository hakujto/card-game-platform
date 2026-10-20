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

func setupMatchApp(t *testing.T) (*gorm.DB, *fiber.App) {
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
	h := handler_app.NewMatchHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewSeasonHandler(db).RegisterRoutes(app)
	handler_app.NewTournamentHandler(db).RegisterRoutes(app)
	handler_app.NewTournamentRoundHandler(db).RegisterRoutes(app)
	return db, app
}

func postMatch(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListMatch(t *testing.T) {
	_, app := setupMatchApp(t)
	req := httptest.NewRequest("GET", "/api/matches", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateMatch(t *testing.T) {
	db, app := setupMatchApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	_ = depSeasonResp
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	depTournamentResp := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	_ = depTournamentResp
	depTournamentID := uint(depTournamentResp["id"].(float64))
	_ = depTournamentID
	depTournamentRoundResp := postTournamentRound(t, app, db, map[string]interface{}{"round_number": 1, "status": "Pending", "time_limit_minutes": 1, "tournament_id": depTournamentID})
	_ = depTournamentRoundResp
	depTournamentRoundID := uint(depTournamentRoundResp["id"].(float64))
	_ = depTournamentRoundID
	body := map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["player1_wins"])
	assert.NotNil(t, result["player2_wins"])
	assert.NotNil(t, result["started_at"])
	assert.NotNil(t, result["ended_at"])
}

func TestGetMatch(t *testing.T) {
	db, app := setupMatchApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	depTournamentResp := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	depTournamentID := uint(depTournamentResp["id"].(float64))
	_ = depTournamentID
	depTournamentRoundResp := postTournamentRound(t, app, db, map[string]interface{}{"round_number": 1, "status": "Pending", "time_limit_minutes": 1, "tournament_id": depTournamentID})
	depTournamentRoundID := uint(depTournamentRoundResp["id"].(float64))
	_ = depTournamentRoundID
	created := postMatch(t, app, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/matches/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
