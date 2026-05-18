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

func setupOrderDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewOrderHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postOrder(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestOrder_List(t *testing.T) {
	_, r := setupOrderDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/orders", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrder_Create(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	body := map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayer1ID}
	result := postOrder(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestOrder_Get(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/orders/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrder_Update(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"total": 0}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/orders/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrder_Delete(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/orders/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestOrder_Rule_PaidRequiresPaidAt_Violated(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"status": "Paid", "total": 0.0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00Z", "player_id": depPlayerRID, "paid_at": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestOrder_Rule_ShippedRequiresTracking_Violated(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"status": "Shipped", "total": 0.0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00Z", "player_id": depPlayerRID, "tracking_number": nil}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestOrder_Rule_TotalNotNegative_Violated(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerRID := createDepPlayer(t, r, db)
	_ = depPlayerRID
	body := map[string]interface{}{"status": "Pending", "total": -1, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00Z", "player_id": depPlayerRID}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
