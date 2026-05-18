package handler_tournaments_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func createDepSeason(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/seasons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepPlayer(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepTournament(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 1, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "season_id": 1, "organizer_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepDeck(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "draws": 1, "player_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/decks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepTournamentRound(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"round_number": 1, "status": "Pending", "time_limit_minutes": 1, "tournament_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_rounds", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepMatch(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"status": "Pending", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepTournamentPrize(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0.0, "season_points": 1, "tournament_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_prizes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}
