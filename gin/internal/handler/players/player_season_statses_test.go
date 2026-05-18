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

func setupPlayerSeasonStatsDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewPlayerSeasonStatsHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewPlayerHandler(db).RegisterRoutes(r)
	return db, r
}

func postPlayerSeasonStats(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_season_statses", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestPlayerSeasonStats_List(t *testing.T) {
	_, r := setupPlayerSeasonStatsDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_season_statses", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerSeasonStats_Create(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	body := map[string]interface{}{"wins": 0, "losses": 0, "draws": 1, "tournament_wins": 0, "season_points": 0, "player_id": depPlayer1ID, "season_id": depSeason1ID}
	result := postPlayerSeasonStats(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestPlayerSeasonStats_Get(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	created := postPlayerSeasonStats(t, r, db, map[string]interface{}{"wins": 0, "losses": 0, "draws": 1, "tournament_wins": 0, "season_points": 0, "player_id": depPlayer2ID, "season_id": depSeason2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_season_statses/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerSeasonStats_Update(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	created := postPlayerSeasonStats(t, r, db, map[string]interface{}{"wins": 0, "losses": 0, "draws": 1, "tournament_wins": 0, "season_points": 0, "player_id": depPlayer3ID, "season_id": depSeason3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"wins": 0}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/player_season_statses/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerSeasonStats_Delete(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	created := postPlayerSeasonStats(t, r, db, map[string]interface{}{"wins": 0, "losses": 0, "draws": 1, "tournament_wins": 0, "season_points": 0, "player_id": depPlayer4ID, "season_id": depSeason4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/player_season_statses/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestPlayerSeasonStats_Rule_WinsNotNegative_Violated(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	body := map[string]interface{}{"wins": -1, "losses": 1, "draws": 1, "tournament_wins": 1, "season_points": 1, "player_id": depPlayerRID, "season_id": depSeasonRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_season_statses", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestPlayerSeasonStats_Rule_LossesNotNegative_Violated(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	body := map[string]interface{}{"wins": 1, "losses": -1, "draws": 1, "tournament_wins": 1, "season_points": 1, "player_id": depPlayerRID, "season_id": depSeasonRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_season_statses", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestPlayerSeasonStats_Rule_TournamentWinsNotNegative_Violated(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	body := map[string]interface{}{"wins": 1, "losses": 1, "draws": 1, "tournament_wins": -1, "season_points": 1, "player_id": depPlayerRID, "season_id": depSeasonRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_season_statses", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestPlayerSeasonStats_Rule_SeasonPointsNotNegative_Violated(t *testing.T) {
	db, r := setupPlayerSeasonStatsDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	body := map[string]interface{}{"wins": 1, "losses": 1, "draws": 1, "tournament_wins": 1, "season_points": -1, "player_id": depPlayerRID, "season_id": depSeasonRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_season_statses", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
