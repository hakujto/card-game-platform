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

func setupGameDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewGameHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postGame(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestGame_List(t *testing.T) {
	_, r := setupGameDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/games", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestGame_Create(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depTournament1ID := createDepTournament(t, r, db)
	_ = depTournament1ID
	depTournamentRound1ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound1ID
	depMatch1ID := createDepMatch(t, r, db)
	_ = depMatch1ID
	body := map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatch1ID}
	result := postGame(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestGame_Get(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depTournament2ID := createDepTournament(t, r, db)
	_ = depTournament2ID
	depTournamentRound2ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound2ID
	depMatch2ID := createDepMatch(t, r, db)
	_ = depMatch2ID
	created := postGame(t, r, db, map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatch2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/games/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestGame_Update(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depTournament3ID := createDepTournament(t, r, db)
	_ = depTournament3ID
	depTournamentRound3ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound3ID
	depMatch3ID := createDepMatch(t, r, db)
	_ = depMatch3ID
	created := postGame(t, r, db, map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatch3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"game_number": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/games/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestGame_Delete(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depTournament4ID := createDepTournament(t, r, db)
	_ = depTournament4ID
	depTournamentRound4ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound4ID
	depMatch4ID := createDepMatch(t, r, db)
	_ = depMatch4ID
	created := postGame(t, r, db, map[string]interface{}{"game_number": 1, "turns_played": 1, "duration_seconds": 1, "match_id": depMatch4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/games/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestGame_Rule_GameNumberRange_Violated(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	depMatchRID := createDepMatch(t, r, db)
	_ = depMatchRID
	body := map[string]interface{}{"game_number": 4, "match_id": depMatchRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestGame_Rule_TurnsPlayedPositive_Violated(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	depMatchRID := createDepMatch(t, r, db)
	_ = depMatchRID
	body := map[string]interface{}{"game_number": 1, "match_id": depMatchRID, "turns_played": 0}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestGame_Rule_DurationPositive_Violated(t *testing.T) {
	db, r := setupGameDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	depMatchRID := createDepMatch(t, r, db)
	_ = depMatchRID
	body := map[string]interface{}{"game_number": 1, "match_id": depMatchRID, "duration_seconds": 0}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/games", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
