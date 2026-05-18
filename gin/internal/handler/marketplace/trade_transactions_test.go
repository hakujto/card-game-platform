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

func setupTradeTransactionDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTradeTransactionHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewTradeListingHandler(db).RegisterRoutes(r)
	return db, r
}

func postTradeTransaction(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_transactions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTradeTransaction_List(t *testing.T) {
	_, r := setupTradeTransactionDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_transactions", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeTransaction_Create(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	depTradeListing1ID := createDepTradeListing(t, r, db)
	_ = depTradeListing1ID
	body := map[string]interface{}{"final_price": 1, "platform_fee": 0, "status": "Pending", "completed_at": "2024-01-01T00:00:00Z", "listing_id": depTradeListing1ID, "buyer_id": depPlayer1ID, "seller_id": depPlayer1ID}
	result := postTradeTransaction(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTradeTransaction_Get(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	depTradeListing2ID := createDepTradeListing(t, r, db)
	_ = depTradeListing2ID
	created := postTradeTransaction(t, r, db, map[string]interface{}{"final_price": 1, "platform_fee": 0, "status": "Pending", "completed_at": "2024-01-01T00:00:00Z", "listing_id": depTradeListing2ID, "buyer_id": depPlayer2ID, "seller_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_transactions/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeTransaction_Update(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	depTradeListing3ID := createDepTradeListing(t, r, db)
	_ = depTradeListing3ID
	created := postTradeTransaction(t, r, db, map[string]interface{}{"final_price": 1, "platform_fee": 0, "status": "Pending", "completed_at": "2024-01-01T00:00:00Z", "listing_id": depTradeListing3ID, "buyer_id": depPlayer3ID, "seller_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"final_price": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/trade_transactions/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeTransaction_Delete(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	depTradeListing4ID := createDepTradeListing(t, r, db)
	_ = depTradeListing4ID
	created := postTradeTransaction(t, r, db, map[string]interface{}{"final_price": 1, "platform_fee": 0, "status": "Pending", "completed_at": "2024-01-01T00:00:00Z", "listing_id": depTradeListing4ID, "buyer_id": depPlayer4ID, "seller_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/trade_transactions/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestTradeTransaction_Rule_FeeNotNegative_Violated(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	depTradeListingRID := createDepTradeListing(t, r, db)
	_ = depTradeListingRID
	body := map[string]interface{}{"final_price": 0.0, "platform_fee": -1, "status": "Pending", "listing_id": depTradeListingRID, "buyer_id": depPlayerRID, "seller_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_transactions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTradeTransaction_Rule_FinalPricePositive_Violated(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	depTradeListingRID := createDepTradeListing(t, r, db)
	_ = depTradeListingRID
	body := map[string]interface{}{"final_price": 0, "platform_fee": 0.0, "status": "Pending", "listing_id": depTradeListingRID, "buyer_id": depPlayerRID, "seller_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_transactions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestTradeTransaction_Rule_CompletedRequiresCompletedAt_Violated(t *testing.T) {
	db, r := setupTradeTransactionDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depCardSetRID := createDepCardSet(t, r, db)
	_ = depCardSetRID
	depCardRID := createDepCard(t, r, db)
	_ = depCardRID
	depTradeListingRID := createDepTradeListing(t, r, db)
	_ = depTradeListingRID
	body := map[string]interface{}{"final_price": 0.0, "platform_fee": 0.0, "status": "Completed", "listing_id": depTradeListingRID, "buyer_id": depPlayerRID, "seller_id": depPlayerRID, "completed_at": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_transactions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
