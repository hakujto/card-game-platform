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

func setupPlayerAchievementDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewPlayerAchievementHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewPlayerHandler(db).RegisterRoutes(r)
	handler_app.NewAchievementHandler(db).RegisterRoutes(r)
	return db, r
}

func postPlayerAchievement(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestPlayerAchievement_List(t *testing.T) {
	_, r := setupPlayerAchievementDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_achievements", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerAchievement_Create(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depAchievement1ID := createDepAchievement(t, r, db)
	_ = depAchievement1ID
	body := map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": 1, "is_completed": true, "player_id": depPlayer1ID, "achievement_id": depAchievement1ID}
	result := postPlayerAchievement(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestPlayerAchievement_Get(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depAchievement2ID := createDepAchievement(t, r, db)
	_ = depAchievement2ID
	created := postPlayerAchievement(t, r, db, map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": 1, "is_completed": true, "player_id": depPlayer2ID, "achievement_id": depAchievement2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_achievements/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerAchievement_Update(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depAchievement3ID := createDepAchievement(t, r, db)
	_ = depAchievement3ID
	created := postPlayerAchievement(t, r, db, map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": 1, "is_completed": true, "player_id": depPlayer3ID, "achievement_id": depAchievement3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/player_achievements/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerAchievement_Delete(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depAchievement4ID := createDepAchievement(t, r, db)
	_ = depAchievement4ID
	created := postPlayerAchievement(t, r, db, map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": 1, "is_completed": true, "player_id": depPlayer4ID, "achievement_id": depAchievement4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/player_achievements/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestPlayerAchievement_Rule_CompletedRequiresProgress_Violated(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depAchievementRID := createDepAchievement(t, r, db)
	_ = depAchievementRID
	body := map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": 0, "is_completed": "true", "player_id": depPlayerRID, "achievement_id": depAchievementRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestPlayerAchievement_Rule_ProgressNotNegative_Violated(t *testing.T) {
	db, r := setupPlayerAchievementDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depAchievementRID := createDepAchievement(t, r, db)
	_ = depAchievementRID
	body := map[string]interface{}{"earned_at": "2024-01-01T00:00:00Z", "progress": -1, "is_completed": true, "player_id": depPlayerRID, "achievement_id": depAchievementRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
