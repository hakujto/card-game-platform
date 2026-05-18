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

func setupTournamentRegistrationDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTournamentRegistrationHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewSeasonHandler(db).RegisterRoutes(r)
	handler_app.NewTournamentHandler(db).RegisterRoutes(r)
	return db, r
}

func postTournamentRegistration(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTournamentRegistration_List(t *testing.T) {
	_, r := setupTournamentRegistrationDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tournament_registrations", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournamentRegistration_Create(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depTournament1ID := createDepTournament(t, r, db)
	_ = depTournament1ID
	depDeck1ID := createDepDeck(t, r, db)
	_ = depDeck1ID
	body := map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournament1ID, "player_id": depPlayer1ID, "deck_id": depDeck1ID}
	result := postTournamentRegistration(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTournamentRegistration_Get(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depTournament2ID := createDepTournament(t, r, db)
	_ = depTournament2ID
	depDeck2ID := createDepDeck(t, r, db)
	_ = depDeck2ID
	created := postTournamentRegistration(t, r, db, map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournament2ID, "player_id": depPlayer2ID, "deck_id": depDeck2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tournament_registrations/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournamentRegistration_Update(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depTournament3ID := createDepTournament(t, r, db)
	_ = depTournament3ID
	depDeck3ID := createDepDeck(t, r, db)
	_ = depDeck3ID
	created := postTournamentRegistration(t, r, db, map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournament3ID, "player_id": depPlayer3ID, "deck_id": depDeck3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"points_earned": 0}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/tournament_registrations/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTournamentRegistration_Delete(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depTournament4ID := createDepTournament(t, r, db)
	_ = depTournament4ID
	depDeck4ID := createDepDeck(t, r, db)
	_ = depDeck4ID
	created := postTournamentRegistration(t, r, db, map[string]interface{}{"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournament4ID, "player_id": depPlayer4ID, "deck_id": depDeck4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/tournament_registrations/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestTournamentRegistration_Rule_PointsEarnedNotNegative_Violated(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depDeckRID := createDepDeck(t, r, db)
	_ = depDeckRID
	body := map[string]interface{}{"status": "Registered", "points_earned": -1, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournamentRID, "player_id": depPlayerRID, "deck_id": depDeckRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTournamentRegistration_Rule_FinalStandingPositive_Violated(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depDeckRID := createDepDeck(t, r, db)
	_ = depDeckRID
	body := map[string]interface{}{"status": "Registered", "points_earned": 1, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournamentRID, "player_id": depPlayerRID, "deck_id": depDeckRID, "final_standing": 0}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTournamentRegistration_Rule_SeedPositive_Violated(t *testing.T) {
	db, r := setupTournamentRegistrationDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depDeckRID := createDepDeck(t, r, db)
	_ = depDeckRID
	body := map[string]interface{}{"status": "Registered", "points_earned": 1, "registered_at": "2024-01-01T00:00:00Z", "tournament_id": depTournamentRID, "player_id": depPlayerRID, "deck_id": depDeckRID, "seed": 0}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tournament_registrations", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
