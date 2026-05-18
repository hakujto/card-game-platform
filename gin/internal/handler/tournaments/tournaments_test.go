package handler_tournaments_test

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

	handler_app "cards_project/internal/handler/tournaments"
	model "cards_project/internal/model/tournaments"
)

func setupTournamentDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTournamentHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postTournament(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTournament_List(t *testing.T) {
	_, r := setupTournamentDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tournaments", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournament_Create(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	body := map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeason1ID, "organizer_id": depPlayer1ID}
	result := postTournament(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTournament_Get(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	created := postTournament(t, r, db, map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeason2ID, "organizer_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tournaments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournament_Update(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	created := postTournament(t, r, db, map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeason3ID, "organizer_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/tournaments/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournament_Delete(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	created := postTournament(t, r, db, map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:01Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeason4ID, "organizer_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/tournaments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestTournament_Rule_MaxPlayersPositive_Violated(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 513, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonRID, "organizer_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTournament_Rule_EntryFeeNotNegative_Violated(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 1, "entry_fee": -1, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonRID, "organizer_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTournament_Rule_PrizePoolNotNegative_Violated(t *testing.T) {
	db, r := setupTournamentDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 1, "entry_fee": 0.0, "prize_pool": -1, "start_time": "2024-01-01T00:00:00Z", "is_online": true, "created_at": "2024-01-01T00:00:00Z", "season_id": depSeasonRID, "organizer_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournaments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
