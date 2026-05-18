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

func setupOrderItemDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.Tradelisting{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewOrderItemHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postOrderItem(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/order_items", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestOrderItem_List(t *testing.T) {
	_, r := setupOrderItemDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/order_items", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrderItem_Create(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depOrder1ID := createDepOrder(t, r, db)
	_ = depOrder1ID
	depProduct1ID := createDepProduct(t, r, db)
	_ = depProduct1ID
	body := map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrder1ID, "product_id": depProduct1ID}
	result := postOrderItem(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestOrderItem_Get(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depOrder2ID := createDepOrder(t, r, db)
	_ = depOrder2ID
	depProduct2ID := createDepProduct(t, r, db)
	_ = depProduct2ID
	created := postOrderItem(t, r, db, map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrder2ID, "product_id": depProduct2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/order_items/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrderItem_Update(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depOrder3ID := createDepOrder(t, r, db)
	_ = depOrder3ID
	depProduct3ID := createDepProduct(t, r, db)
	_ = depProduct3ID
	created := postOrderItem(t, r, db, map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrder3ID, "product_id": depProduct3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"quantity": 1}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/order_items/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrderItem_Delete(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depOrder4ID := createDepOrder(t, r, db)
	_ = depOrder4ID
	depProduct4ID := createDepProduct(t, r, db)
	_ = depProduct4ID
	created := postOrderItem(t, r, db, map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrder4ID, "product_id": depProduct4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/order_items/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestOrderItem_Rule_QuantityPositive_Violated(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depOrderRID := createDepOrder(t, r, db)
	_ = depOrderRID
	depProductRID := createDepProduct(t, r, db)
	_ = depProductRID
	body := map[string]interface{}{"quantity": 0, "price_at_purchase": 0.0, "foil": true, "order_id": depOrderRID, "product_id": depProductRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/order_items", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestOrderItem_Rule_PriceNotNegative_Violated(t *testing.T) {
	db, r := setupOrderItemDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	depOrderRID := createDepOrder(t, r, db)
	_ = depOrderRID
	depProductRID := createDepProduct(t, r, db)
	_ = depProductRID
	body := map[string]interface{}{"quantity": 1, "price_at_purchase": -1, "foil": true, "order_id": depOrderRID, "product_id": depProductRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/order_items", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
