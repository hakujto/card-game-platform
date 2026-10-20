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

func setupGameApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	app := fiber.New()
	h := handler_app.NewGameHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewSeasonHandler(db).RegisterRoutes(app)
	handler_app.NewTournamentHandler(db).RegisterRoutes(app)
	handler_app.NewTournamentRoundHandler(db).RegisterRoutes(app)
	handler_app.NewMatchHandler(db).RegisterRoutes(app)
	return db, app
}

func postGame(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListGame(t *testing.T) {
	_, app := setupGameApp(t)
	req := httptest.NewRequest("GET", "/api/games", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateGame(t *testing.T) {
	db, app := setupGameApp(t)
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
	depMatchResp := postMatch(t, app, db, map[string]interface{}{"status": "Pending", "player1_wins": 1, "player2_wins": 1, "round_id": depTournamentRoundID})
	_ = depMatchResp
	depMatchID := uint(depMatchResp["id"].(float64))
	_ = depMatchID
	body := map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatchID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["game_number"])
	assert.NotNil(t, result["turns_played"])
	assert.NotNil(t, result["duration_seconds"])
}

func TestGetGame(t *testing.T) {
	db, app := setupGameApp(t)
	depSeasonResp := postSeason(t, app, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true})
	depSeasonID := uint(depSeasonResp["id"].(float64))
	_ = depSeasonID
	depTournamentResp := postTournament(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonID})
	depTournamentID := uint(depTournamentResp["id"].(float64))
	_ = depTournamentID
	depTournamentRoundResp := postTournamentRound(t, app, db, map[string]interface{}{"round_number": 1, "status": "Pending", "time_limit_minutes": 1, "tournament_id": depTournamentID})
	depTournamentRoundID := uint(depTournamentRoundResp["id"].(float64))
	_ = depTournamentRoundID
	depMatchResp := postMatch(t, app, db, map[string]interface{}{"status": "Pending", "player1_wins": 1, "player2_wins": 1, "round_id": depTournamentRoundID})
	depMatchID := uint(depMatchResp["id"].(float64))
	_ = depMatchID
	created := postGame(t, app, db, map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatchID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/games/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
