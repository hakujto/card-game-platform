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

func setupDeckTagAssignmentDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDeckTagAssignmentHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewDeckHandler(db).RegisterRoutes(r)
	handler_app.NewDeckTagHandler(db).RegisterRoutes(r)
	return db, r
}

func postDeckTagAssignment(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/deck_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestDeckTagAssignment_List(t *testing.T) {
	_, r := setupDeckTagAssignmentDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/deck_tag_assignments", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckTagAssignment_Create(t *testing.T) {
	db, r := setupDeckTagAssignmentDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depDeck1ID := createDepDeck(t, r, db)
	_ = depDeck1ID
	depDeckTag1ID := createDepDeckTag(t, r, db)
	_ = depDeckTag1ID
	body := map[string]interface{}{"deck_id": depDeck1ID, "tag_id": depDeckTag1ID}
	result := postDeckTagAssignment(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestDeckTagAssignment_Get(t *testing.T) {
	db, r := setupDeckTagAssignmentDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depDeck2ID := createDepDeck(t, r, db)
	_ = depDeck2ID
	depDeckTag2ID := createDepDeckTag(t, r, db)
	_ = depDeckTag2ID
	created := postDeckTagAssignment(t, r, db, map[string]interface{}{"deck_id": depDeck2ID, "tag_id": depDeckTag2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/deck_tag_assignments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckTagAssignment_Update(t *testing.T) {
	db, r := setupDeckTagAssignmentDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depDeck3ID := createDepDeck(t, r, db)
	_ = depDeck3ID
	depDeckTag3ID := createDepDeckTag(t, r, db)
	_ = depDeckTag3ID
	created := postDeckTagAssignment(t, r, db, map[string]interface{}{"deck_id": depDeck3ID, "tag_id": depDeckTag3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "updated"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/deck_tag_assignments/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckTagAssignment_Delete(t *testing.T) {
	db, r := setupDeckTagAssignmentDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depDeck4ID := createDepDeck(t, r, db)
	_ = depDeck4ID
	depDeckTag4ID := createDepDeckTag(t, r, db)
	_ = depDeckTag4ID
	created := postDeckTagAssignment(t, r, db, map[string]interface{}{"deck_id": depDeck4ID, "tag_id": depDeckTag4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/deck_tag_assignments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
