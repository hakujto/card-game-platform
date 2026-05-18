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

func setupCardAbilityDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewCardAbilityHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewCardSetHandler(db).RegisterRoutes(r)
	handler_app.NewCardHandler(db).RegisterRoutes(r)
	return db, r
}

func postCardAbility(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/card_abilities", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestCardAbility_List(t *testing.T) {
	_, r := setupCardAbilityDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/card_abilities", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardAbility_Create(t *testing.T) {
	db, r := setupCardAbilityDB(t)
	_ = db
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	body := map[string]interface{}{"ability_type": "Keyword", "keyword": "test", "ability_text": "test", "card_id": depCard1ID}
	result := postCardAbility(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestCardAbility_Get(t *testing.T) {
	db, r := setupCardAbilityDB(t)
	_ = db
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	created := postCardAbility(t, r, db, map[string]interface{}{"ability_type": "Keyword", "keyword": "test", "ability_text": "test", "card_id": depCard2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/card_abilities/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardAbility_Update(t *testing.T) {
	db, r := setupCardAbilityDB(t)
	_ = db
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	created := postCardAbility(t, r, db, map[string]interface{}{"ability_type": "Keyword", "keyword": "test", "ability_text": "test", "card_id": depCard3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"ability_text": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/card_abilities/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCardAbility_Delete(t *testing.T) {
	db, r := setupCardAbilityDB(t)
	_ = db
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	created := postCardAbility(t, r, db, map[string]interface{}{"ability_type": "Keyword", "keyword": "test", "ability_text": "test", "card_id": depCard4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/card_abilities/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestCardAbility_Rule_KeywordAbilityRequiresKeyword_Violated(t *testing.T) {
	db, r := setupCardAbilityDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"ability_type": "Keyword", "ability_text": "test", "card_id": depCardRID, "keyword": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/card_abilities", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
