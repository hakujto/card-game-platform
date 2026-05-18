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

func setupSeasonDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewSeasonHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postSeason(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/seasons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestSeason_List(t *testing.T) {
	_, r := setupSeasonDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/seasons", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestSeason_Create(t *testing.T) {
	db, r := setupSeasonDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true}
	result := postSeason(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestSeason_Get(t *testing.T) {
	db, r := setupSeasonDB(t)
	_ = db
	created := postSeason(t, r, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/seasons/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestSeason_Update(t *testing.T) {
	db, r := setupSeasonDB(t)
	_ = db
	created := postSeason(t, r, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/seasons/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestSeason_Delete(t *testing.T) {
	db, r := setupSeasonDB(t)
	_ = db
	created := postSeason(t, r, db, map[string]interface{}{"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/seasons/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
