package handler_players_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

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

func createDepCardSet(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true}
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

func createDepAchievement(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepCraftingRecipe(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"dust_cost": 1, "is_available": true, "result_card_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/crafting_recipes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}
