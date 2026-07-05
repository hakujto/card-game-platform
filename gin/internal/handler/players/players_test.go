package handler_players_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"bytes"
	"fmt"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupPlayerDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewPlayerHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postPlayer(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestPlayer_List(t *testing.T) {
	_, r := setupPlayerDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/players", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayer_Search(t *testing.T) {
	_, r := setupPlayerDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/players?q=test", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayer_Create(t *testing.T) {
	db, r := setupPlayerDB(t)
	_ = db
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"}
	result := postPlayer(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestPlayer_Get(t *testing.T) {
	db, r := setupPlayerDB(t)
	_ = db
	created := postPlayer(t, r, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/players/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayer_Update(t *testing.T) {
	db, r := setupPlayerDB(t)
	_ = db
	created := postPlayer(t, r, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "Bronze", "rating": 1000, "peak_rating": 1000, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/players/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayer_Rule_RatingRange_Violated(t *testing.T) {
	db, r := setupPlayerDB(t)
	_ = db
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "Bronze", "rating": 10000, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestPlayer_Rule_DisplayNameNotEmpty_Violated(t *testing.T) {
	db, r := setupPlayerDB(t)
	_ = db
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": nil, "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
