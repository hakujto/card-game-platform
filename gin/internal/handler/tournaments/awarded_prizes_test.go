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

func setupAwardedPrizeDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewAwardedPrizeHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postAwardedPrize(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/awarded_prizes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestAwardedPrize_List(t *testing.T) {
	_, r := setupAwardedPrizeDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/awarded_prizes", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAwardedPrize_Create(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeason1ID := createDepSeason(t, r, db)
	_ = depSeason1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depTournament1ID := createDepTournament(t, r, db)
	_ = depTournament1ID
	depTournamentPrize1ID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrize1ID
	body := map[string]interface{}{"final_placement": 1, "awarded_at": "2024-01-01T00:00:00Z", "claimed": true, "claimed_at": "2024-01-01T00:00:00Z", "prize_id": depTournamentPrize1ID, "player_id": depPlayer1ID}
	result := postAwardedPrize(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestAwardedPrize_Get(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeason2ID := createDepSeason(t, r, db)
	_ = depSeason2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depTournament2ID := createDepTournament(t, r, db)
	_ = depTournament2ID
	depTournamentPrize2ID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrize2ID
	created := postAwardedPrize(t, r, db, map[string]interface{}{"final_placement": 1, "awarded_at": "2024-01-01T00:00:00Z", "claimed": true, "claimed_at": "2024-01-01T00:00:00Z", "prize_id": depTournamentPrize2ID, "player_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/awarded_prizes/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAwardedPrize_Update(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeason3ID := createDepSeason(t, r, db)
	_ = depSeason3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depTournament3ID := createDepTournament(t, r, db)
	_ = depTournament3ID
	depTournamentPrize3ID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrize3ID
	created := postAwardedPrize(t, r, db, map[string]interface{}{"final_placement": 1, "awarded_at": "2024-01-01T00:00:00Z", "claimed": true, "claimed_at": "2024-01-01T00:00:00Z", "prize_id": depTournamentPrize3ID, "player_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"final_placement": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/awarded_prizes/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAwardedPrize_Delete(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeason4ID := createDepSeason(t, r, db)
	_ = depSeason4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depTournament4ID := createDepTournament(t, r, db)
	_ = depTournament4ID
	depTournamentPrize4ID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrize4ID
	created := postAwardedPrize(t, r, db, map[string]interface{}{"final_placement": 1, "awarded_at": "2024-01-01T00:00:00Z", "claimed": true, "claimed_at": "2024-01-01T00:00:00Z", "prize_id": depTournamentPrize4ID, "player_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/awarded_prizes/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestAwardedPrize_Rule_ClaimedRequiresClaimedAt_Violated(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentPrizeRID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrizeRID
	body := map[string]interface{}{"final_placement": 1, "awarded_at": "2024-01-01T00:00:00Z", "claimed": "true", "prize_id": depTournamentPrizeRID, "player_id": depPlayerRID, "claimed_at": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/awarded_prizes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAwardedPrize_Rule_FinalPlacementPositive_Violated(t *testing.T) {
	db, r := setupAwardedPrizeDB(t)
	_ = db
	depSeasonRID := createDepSeason(t, r, db)
	_ = depSeasonRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depTournamentRID := createDepTournament(t, r, db)
	_ = depTournamentRID
	depTournamentPrizeRID := createDepTournamentPrize(t, r, db)
	_ = depTournamentPrizeRID
	body := map[string]interface{}{"final_placement": 0, "awarded_at": "2024-01-01T00:00:00Z", "claimed": true, "prize_id": depTournamentPrizeRID, "player_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/awarded_prizes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
