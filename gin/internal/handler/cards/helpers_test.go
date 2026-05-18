package handler_cards_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func createDepCardSet(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepCard(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
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

func createDepDeck(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "format": "Standard", "is_public": true, "is_tournament_legal": true, "wins": 1, "losses": 1, "player_id": 1}
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

func createDepDeckTag(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/deck_tags", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}
