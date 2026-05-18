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

func setupDraftParticipantDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDraftParticipantHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postDraftParticipant(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_participants", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestDraftParticipant_List(t *testing.T) {
	_, r := setupDraftParticipantDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_participants", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftParticipant_Create(t *testing.T) {
	db, r := setupDraftParticipantDB(t)
	_ = db
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depDraftSession1ID := createDepDraftSession(t, r, db)
	_ = depDraftSession1ID
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	body := map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSession1ID, "player_id": depPlayer1ID}
	result := postDraftParticipant(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestDraftParticipant_Get(t *testing.T) {
	db, r := setupDraftParticipantDB(t)
	_ = db
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depDraftSession2ID := createDepDraftSession(t, r, db)
	_ = depDraftSession2ID
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	created := postDraftParticipant(t, r, db, map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSession2ID, "player_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_participants/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftParticipant_Update(t *testing.T) {
	db, r := setupDraftParticipantDB(t)
	_ = db
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depDraftSession3ID := createDepDraftSession(t, r, db)
	_ = depDraftSession3ID
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	created := postDraftParticipant(t, r, db, map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSession3ID, "player_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"seat_number": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/draft_participants/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftParticipant_Delete(t *testing.T) {
	db, r := setupDraftParticipantDB(t)
	_ = db
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depDraftSession4ID := createDepDraftSession(t, r, db)
	_ = depDraftSession4ID
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	created := postDraftParticipant(t, r, db, map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z", "session_id": depDraftSession4ID, "player_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/draft_participants/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
