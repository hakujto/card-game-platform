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

func setupTradeDisputeDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTradeDisputeHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewTradeListingHandler(db).RegisterRoutes(r)
	handler_app.NewTradeTransactionHandler(db).RegisterRoutes(r)
	return db, r
}

func postTradeDispute(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_disputes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestTradeDispute_List(t *testing.T) {
	_, r := setupTradeDisputeDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_disputes", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeDispute_Create(t *testing.T) {
	db, r := setupTradeDisputeDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depCardSet1ID := createDepCardSet(t, r, db)
	_ = depCardSet1ID
	depCard1ID := createDepCard(t, r, db)
	_ = depCard1ID
	depTradeListing1ID := createDepTradeListing(t, r, db)
	_ = depTradeListing1ID
	depTradeTransaction1ID := createDepTradeTransaction(t, r, db)
	_ = depTradeTransaction1ID
	body := map[string]interface{}{"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00Z", "transaction_id": depTradeTransaction1ID, "opened_by_id": depPlayer1ID}
	result := postTradeDispute(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestTradeDispute_Get(t *testing.T) {
	db, r := setupTradeDisputeDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depCardSet2ID := createDepCardSet(t, r, db)
	_ = depCardSet2ID
	depCard2ID := createDepCard(t, r, db)
	_ = depCard2ID
	depTradeListing2ID := createDepTradeListing(t, r, db)
	_ = depTradeListing2ID
	depTradeTransaction2ID := createDepTradeTransaction(t, r, db)
	_ = depTradeTransaction2ID
	created := postTradeDispute(t, r, db, map[string]interface{}{"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00Z", "transaction_id": depTradeTransaction2ID, "opened_by_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_disputes/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeDispute_Update(t *testing.T) {
	db, r := setupTradeDisputeDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depCardSet3ID := createDepCardSet(t, r, db)
	_ = depCardSet3ID
	depCard3ID := createDepCard(t, r, db)
	_ = depCard3ID
	depTradeListing3ID := createDepTradeListing(t, r, db)
	_ = depTradeListing3ID
	depTradeTransaction3ID := createDepTradeTransaction(t, r, db)
	_ = depTradeTransaction3ID
	created := postTradeDispute(t, r, db, map[string]interface{}{"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00Z", "transaction_id": depTradeTransaction3ID, "opened_by_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"description": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/trade_disputes/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestTradeDispute_Delete(t *testing.T) {
	db, r := setupTradeDisputeDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depCardSet4ID := createDepCardSet(t, r, db)
	_ = depCardSet4ID
	depCard4ID := createDepCard(t, r, db)
	_ = depCard4ID
	depTradeListing4ID := createDepTradeListing(t, r, db)
	_ = depTradeListing4ID
	depTradeTransaction4ID := createDepTradeTransaction(t, r, db)
	_ = depTradeTransaction4ID
	created := postTradeDispute(t, r, db, map[string]interface{}{"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00Z", "transaction_id": depTradeTransaction4ID, "opened_by_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/trade_disputes/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
