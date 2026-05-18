package handler_cards_test

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

	handler_app "cards_project/internal/handler/cards"
	model "cards_project/internal/model/cards"
)

func setupCardSetDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewCardSetHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postCardSet(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestCardSet_List(t *testing.T) {
	_, r := setupCardSetDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/card_sets", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardSet_Create(t *testing.T) {
	db, r := setupCardSetDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1}
	result := postCardSet(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestCardSet_Get(t *testing.T) {
	db, r := setupCardSetDB(t)
	_ = db
	created := postCardSet(t, r, db, map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/card_sets/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardSet_Update(t *testing.T) {
	db, r := setupCardSetDB(t)
	_ = db
	created := postCardSet(t, r, db, map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/card_sets/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardSet_Delete(t *testing.T) {
	db, r := setupCardSetDB(t)
	_ = db
	created := postCardSet(t, r, db, map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/card_sets/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
