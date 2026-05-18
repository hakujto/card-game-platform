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

func setupStreamDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewStreamHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postStream(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/streams", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestStream_List(t *testing.T) {
	_, r := setupStreamDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/streams", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestStream_Create(t *testing.T) {
	db, r := setupStreamDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	body := map[string]interface{}{"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Ended", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z", "streamer_id": depPlayer1ID}
	result := postStream(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestStream_Get(t *testing.T) {
	db, r := setupStreamDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	created := postStream(t, r, db, map[string]interface{}{"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Ended", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z", "streamer_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/streams/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestStream_Update(t *testing.T) {
	db, r := setupStreamDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	created := postStream(t, r, db, map[string]interface{}{"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Ended", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z", "streamer_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"title": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/streams/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestStream_Delete(t *testing.T) {
	db, r := setupStreamDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	created := postStream(t, r, db, map[string]interface{}{"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Ended", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z", "streamer_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/streams/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestStream_Rule_ViewerCountNotNegative_Violated(t *testing.T) {
	db, r := setupStreamDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": -1, "scheduled_start": "2024-01-01T00:00:00Z", "streamer_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/streams", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
