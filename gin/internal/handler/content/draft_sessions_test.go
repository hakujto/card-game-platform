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

func setupDraftSessionDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDraftSessionHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postDraftSession(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_sessions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestDraftSession_List(t *testing.T) {
	_, r := setupDraftSessionDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_sessions", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftSession_Create(t *testing.T) {
	db, r := setupDraftSessionDB(t)
	_ = db
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	body := map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "created_at": "2024-01-01T00:00:00Z", "card_set_id": depCardSet1ID}
	result := postDraftSession(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestDraftSession_Get(t *testing.T) {
	db, r := setupDraftSessionDB(t)
	_ = db
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	created := postDraftSession(t, r, db, map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "created_at": "2024-01-01T00:00:00Z", "card_set_id": depCardSet2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_sessions/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftSession_Update(t *testing.T) {
	db, r := setupDraftSessionDB(t)
	_ = db
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	created := postDraftSession(t, r, db, map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "created_at": "2024-01-01T00:00:00Z", "card_set_id": depCardSet3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"seats": 2}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/draft_sessions/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDraftSession_Delete(t *testing.T) {
	db, r := setupDraftSessionDB(t)
	_ = db
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	created := postDraftSession(t, r, db, map[string]interface{}{"status": "Completed", "draft_type": "Booster", "seats": 2, "created_at": "2024-01-01T00:00:00Z", "card_set_id": depCardSet4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/draft_sessions/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestDraftSession_Rule_SeatsRange_Violated(t *testing.T) {
	db, r := setupDraftSessionDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 17, "created_at": "2024-01-01T00:00:00Z", "card_set_id": depCardSetRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/draft_sessions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
