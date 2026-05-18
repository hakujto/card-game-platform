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

func setupCardDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewCardHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postCard(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestCard_List(t *testing.T) {
	_, r := setupCardDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/cards", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCard_Create(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "legal_formats": "Standard", "is_banned": false, "is_restricted": true, "power_level": 1, "set_id": depCardSet1ID}
	result := postCard(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestCard_Get(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	created := postCard(t, r, db, map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "legal_formats": "Standard", "is_banned": false, "is_restricted": true, "power_level": 1, "set_id": depCardSet2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/cards/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCard_Update(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	created := postCard(t, r, db, map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "legal_formats": "Standard", "is_banned": false, "is_restricted": true, "power_level": 1, "set_id": depCardSet3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/cards/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCard_Delete(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	created := postCard(t, r, db, map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "legal_formats": "Standard", "is_banned": false, "is_restricted": true, "power_level": 1, "set_id": depCardSet4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/cards/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestCard_Rule_CreatureRequiresStats_Violated(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": depCardSetRID, "attack": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCard_Rule_PlaneswalkerRequiresLoyalty_Violated(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"name": "test", "card_type": "Planeswalker", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": depCardSetRID, "loyalty": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCard_Rule_ManaCostRange_Violated(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 21, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": depCardSetRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCard_Rule_PowerLevelRange_Violated(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 11, "set_id": depCardSetRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCard_Rule_NotBannedAndRestricted_Violated(t *testing.T) {
	db, r := setupCardDB(t)
	_ = db
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": "true", "is_restricted": "true", "power_level": 1, "set_id": depCardSetRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
