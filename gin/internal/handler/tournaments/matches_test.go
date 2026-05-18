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

func setupMatchDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewMatchHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postMatch(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestMatch_List(t *testing.T) {
	_, r := setupMatchDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/matches", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMatch_Create(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depTournament1ID := createDepTournament(t, r, db)
	_ = depTournament1ID
	depTournamentRound1ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound1ID
	body := map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "round_id": depTournamentRound1ID, "player1_id": depPlayer1ID}
	result := postMatch(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestMatch_Get(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depTournament2ID := createDepTournament(t, r, db)
	_ = depTournament2ID
	depTournamentRound2ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound2ID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "round_id": depTournamentRound2ID, "player1_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/matches/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMatch_Update(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depTournament3ID := createDepTournament(t, r, db)
	_ = depTournament3ID
	depTournamentRound3ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound3ID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "round_id": depTournamentRound3ID, "player1_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"player1_wins": 0}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/matches/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMatch_Delete(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depTournament4ID := createDepTournament(t, r, db)
	_ = depTournament4ID
	depTournamentRound4ID := createDepTournamentRound(t, r, db)
	_ = depTournamentRound4ID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "round_id": depTournamentRound4ID, "player1_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/matches/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestMatch_Rule_WinsNotNegative_Violated(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	body := map[string]interface{}{"status": "Pending", "player1_wins": -1, "player2_wins": 1, "round_id": depTournamentRoundRID, "player1_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestMatch_Rule_MaxThreeGames_Violated(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	body := map[string]interface{}{"status": "Pending", "player1_wins": 3, "player2_wins": 1, "round_id": depTournamentRoundRID, "player1_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestMatch_Rule_ByeHasNoPlayer2_Violated(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentRoundRID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundRID
	body := map[string]interface{}{"status": "BYE", "player1_wins": 1, "player2_wins": 1, "round_id": depTournamentRoundRID, "player1_id": depPlayerRID, "player2_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
