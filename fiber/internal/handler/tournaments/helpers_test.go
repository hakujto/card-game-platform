package handler_tournaments_test

import (
	"encoding/json"
	"net/http/httptest"
	"bytes"
	"testing"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)
func createDepSeason(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/seasons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepTournament(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepTournamentRound(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"round_number": 1, "status": "Pending", "time_limit_minutes": 1}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournament_rounds", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepMatch(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"status": "Pending", "player1_wins": 1, "player2_wins": 1}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepTournamentPrize(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0.0, "season_points": 1}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/tournament_prizes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}
