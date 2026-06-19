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
	r.Use(func(c *gin.Context) {
		if v := c.GetHeader("X-User-Role"); v != "" {
			c.Set("user_role", v)
		}
		c.Next()
	})
	h := handler_app.NewMatchHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewSeasonHandler(db).RegisterRoutes(r)
	handler_app.NewTournamentHandler(db).RegisterRoutes(r)
	handler_app.NewTournamentRoundHandler(db).RegisterRoutes(r)
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
	body := map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRound1ID, "player1_id": depPlayer1ID}
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
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRound2ID, "player1_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/matches/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMatch_Transition_Pending_To_Active(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/pending-to-active", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestMatch_Transition_Active_To_Completed(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/active-to-completed", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestMatch_Transition_Active_To_Draw(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/active-to-draw", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestMatch_Transition_Pending_To_BYE(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/pending-to-bye", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestMatch_Transition_Completed_To_Active(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/completed-to-active", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusConflict, w.Code)
}

func TestMatch_Transition_Draw_To_Active(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/draw-to-active", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusConflict, w.Code)
}

func TestMatch_Transition_BYE_To_Active(t *testing.T) {
	db, r := setupMatchDB(t)
	_ = db
	depSeasonTID := createDepSeason(t, r, db)
	_ = depSeasonTID
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	depTournamentTID := createDepTournament(t, r, db)
	_ = depTournamentTID
	depTournamentRoundTID := createDepTournamentRound(t, r, db)
	_ = depTournamentRoundTID
	created := postMatch(t, r, db, map[string]interface{}{"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:01Z", "round_id": depTournamentRoundTID, "player1_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/matches/"+id+"/transitions/bye-to-active", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusConflict, w.Code)
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

func TestMatch_Rule_CompletedRequiresStartedAt_Violated(t *testing.T) {
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
	body := map[string]interface{}{"status": "Completed", "player1_wins": 1, "player2_wins": 1, "round_id": depTournamentRoundRID, "player1_id": depPlayerRID, "started_at": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/matches", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
