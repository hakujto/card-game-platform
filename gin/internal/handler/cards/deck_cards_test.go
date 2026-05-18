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

func setupDeckCardDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDeckCardHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewDeckHandler(db).RegisterRoutes(r)
	handler_app.NewCardSetHandler(db).RegisterRoutes(r)
	handler_app.NewCardHandler(db).RegisterRoutes(r)
	return db, r
}

func postDeckCard(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/deck_cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestDeckCard_List(t *testing.T) {
	_, r := setupDeckCardDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/deck_cards", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckCard_Create(t *testing.T) {
	db, r := setupDeckCardDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depDeck1ID := createDepDeck(t, r, db)
	_ = depDeck1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	body := map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeck1ID, "card_id": depCard1ID}
	result := postDeckCard(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestDeckCard_Get(t *testing.T) {
	db, r := setupDeckCardDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depDeck2ID := createDepDeck(t, r, db)
	_ = depDeck2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	created := postDeckCard(t, r, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeck2ID, "card_id": depCard2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/deck_cards/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckCard_Update(t *testing.T) {
	db, r := setupDeckCardDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depDeck3ID := createDepDeck(t, r, db)
	_ = depDeck3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	created := postDeckCard(t, r, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeck3ID, "card_id": depCard3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"quantity": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/deck_cards/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDeckCard_Delete(t *testing.T) {
	db, r := setupDeckCardDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depDeck4ID := createDepDeck(t, r, db)
	_ = depDeck4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	created := postDeckCard(t, r, db, map[string]interface{}{"quantity": 1, "is_commander": true, "deck_id": depDeck4ID, "card_id": depCard4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/deck_cards/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestDeckCard_Rule_QuantityRange_Violated(t *testing.T) {
	db, r := setupDeckCardDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depDeckRID := createDepDeck(t, r, db)
	_ = depDeckRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"quantity": 5, "is_commander": true, "deck_id": depDeckRID, "card_id": depCardRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/deck_cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
