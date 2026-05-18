package handler_players_test

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

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupPlayerCollectionDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewPlayerCollectionHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewPlayerHandler(db).RegisterRoutes(r)
	return db, r
}

func postPlayerCollection(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_collections", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestPlayerCollection_List(t *testing.T) {
	_, r := setupPlayerCollectionDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_collections", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerCollection_Create(t *testing.T) {
	db, r := setupPlayerCollectionDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	body := map[string]interface{}{"quantity": 1, "foil": true, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "Purchase", "player_id": depPlayer1ID, "card_id": depCard1ID}
	result := postPlayerCollection(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestPlayerCollection_Get(t *testing.T) {
	db, r := setupPlayerCollectionDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	created := postPlayerCollection(t, r, db, map[string]interface{}{"quantity": 1, "foil": true, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "Purchase", "player_id": depPlayer2ID, "card_id": depCard2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_collections/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerCollection_Update(t *testing.T) {
	db, r := setupPlayerCollectionDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	created := postPlayerCollection(t, r, db, map[string]interface{}{"quantity": 1, "foil": true, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "Purchase", "player_id": depPlayer3ID, "card_id": depCard3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"quantity": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/player_collections/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestPlayerCollection_Delete(t *testing.T) {
	db, r := setupPlayerCollectionDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	created := postPlayerCollection(t, r, db, map[string]interface{}{"quantity": 1, "foil": true, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "Purchase", "player_id": depPlayer4ID, "card_id": depCard4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/player_collections/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestPlayerCollection_Rule_QuantityPositive_Violated(t *testing.T) {
	db, r := setupPlayerCollectionDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"quantity": 0, "foil": true, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "Purchase", "player_id": depPlayerRID, "card_id": depCardRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/player_collections", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
