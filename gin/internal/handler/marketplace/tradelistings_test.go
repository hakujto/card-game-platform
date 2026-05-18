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

func setupTradelistingDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.Tradelisting{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTradelistingHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postTradelisting(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tradelistings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTradelisting_List(t *testing.T) {
	_, r := setupTradelistingDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tradelistings", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradelisting_Create(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	body := map[string]interface{}{"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayer1ID, "card_id": depCard1ID}
	result := postTradelisting(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTradelisting_Get(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	created := postTradelisting(t, r, db, map[string]interface{}{"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayer2ID, "card_id": depCard2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/tradelistings/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradelisting_Update(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	created := postTradelisting(t, r, db, map[string]interface{}{"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayer3ID, "card_id": depCard3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"foil": true}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/tradelistings/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradelisting_Delete(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	created := postTradelisting(t, r, db, map[string]interface{}{"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayer4ID, "card_id": depCard4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/tradelistings/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestTradelisting_Rule_FixedPriceRequiresAskingPrice_Violated(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayerRID, "card_id": depCardRID, "asking_price": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tradelistings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTradelisting_Rule_AuctionRequiresStartPriceAndEndTime_Violated(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"listing_type": "Auction", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayerRID, "card_id": depCardRID, "auction_start_price": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tradelistings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTradelisting_Rule_QuantityPositive_Violated(t *testing.T) {
	db, r := setupTradelistingDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	body := map[string]interface{}{"listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 10000, "status": "Active", "created_at": "2024-01-01T00:00:00Z", "seller_id": depPlayerRID, "card_id": depCardRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tradelistings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
