package handler_content_test

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

	handler_app "cards_project/internal/handler/content"
	model "cards_project/internal/model/content"
)

func setupDraftPickDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDraftPickHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewDraftSessionHandler(db).RegisterRoutes(r)
	handler_app.NewDraftParticipantHandler(db).RegisterRoutes(r)
	return db, r
}

func postDraftPick(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_picks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestDraftPick_List(t *testing.T) {
	_, r := setupDraftPickDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_picks", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftPick_Create(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depDraftSession1ID := createDepDraftSession(t, r, db)
	_ = depDraftSession1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depDraftParticipant1ID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipant1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	body := map[string]interface{}{"pick_number": 1, "pack_number": 1, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipant1ID, "card_id": depCard1ID}
	result := postDraftPick(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestDraftPick_Get(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depDraftSession2ID := createDepDraftSession(t, r, db)
	_ = depDraftSession2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depDraftParticipant2ID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipant2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	created := postDraftPick(t, r, db, map[string]interface{}{"pick_number": 1, "pack_number": 1, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipant2ID, "card_id": depCard2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_picks/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftPick_Update(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depDraftSession3ID := createDepDraftSession(t, r, db)
	_ = depDraftSession3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depDraftParticipant3ID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipant3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	created := postDraftPick(t, r, db, map[string]interface{}{"pick_number": 1, "pack_number": 1, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipant3ID, "card_id": depCard3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"pick_number": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/draft_picks/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftPick_Delete(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depDraftSession4ID := createDepDraftSession(t, r, db)
	_ = depDraftSession4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depDraftParticipant4ID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipant4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	created := postDraftPick(t, r, db, map[string]interface{}{"pick_number": 1, "pack_number": 1, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipant4ID, "card_id": depCard4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/draft_picks/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestDraftPick_Rule_PickNumberPositive_Violated(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depDraftSessionRID := createDepDraftSession(t, r, db)
	_ = depDraftSessionRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depDraftParticipantRID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipantRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"pick_number": 0, "pack_number": 1, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipantRID, "card_id": depCardRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_picks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestDraftPick_Rule_PackNumberRange_Violated(t *testing.T) {
	db, r := setupDraftPickDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depDraftSessionRID := createDepDraftSession(t, r, db)
	_ = depDraftSessionRID
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depDraftParticipantRID := createDepDraftParticipant(t, r, db)
	_ = depDraftParticipantRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"pick_number": 1, "pack_number": 4, "picked_at": "2024-01-01T00:00:00Z", "participant_id": depDraftParticipantRID, "card_id": depCardRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_picks", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
