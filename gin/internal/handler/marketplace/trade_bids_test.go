package handler_marketplace_test

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

	handler_app "cards_project/internal/handler/marketplace"
	model "cards_project/internal/model/marketplace"
)

func setupTradeBidDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.Tradelisting{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTradeBidHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postTradeBid(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_bids", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTradeBid_List(t *testing.T) {
	_, r := setupTradeBidDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_bids", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeBid_Create(t *testing.T) {
	db, r := setupTradeBidDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	depTradelisting1ID := createDepTradelisting(t, r, db)
	_ = depTradelisting1ID
	body := map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradelisting1ID, "bidder_id": depPlayer1ID}
	result := postTradeBid(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTradeBid_Get(t *testing.T) {
	db, r := setupTradeBidDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	depTradelisting2ID := createDepTradelisting(t, r, db)
	_ = depTradelisting2ID
	created := postTradeBid(t, r, db, map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradelisting2ID, "bidder_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_bids/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeBid_Update(t *testing.T) {
	db, r := setupTradeBidDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	depTradelisting3ID := createDepTradelisting(t, r, db)
	_ = depTradelisting3ID
	created := postTradeBid(t, r, db, map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradelisting3ID, "bidder_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"amount": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/trade_bids/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeBid_Delete(t *testing.T) {
	db, r := setupTradeBidDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	depTradelisting4ID := createDepTradelisting(t, r, db)
	_ = depTradelisting4ID
	created := postTradeBid(t, r, db, map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradelisting4ID, "bidder_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/trade_bids/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestTradeBid_Rule_AmountPositive_Violated(t *testing.T) {
	db, r := setupTradeBidDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	depTradelistingRID := createDepTradelisting(t, r, db)
	_ = depTradelistingRID
	body := map[string]interface{}{"amount": 0, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradelistingRID, "bidder_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_bids", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
