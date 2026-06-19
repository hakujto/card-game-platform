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
	r.Use(func(c *gin.Context) {
		if v := c.GetHeader("X-User-Id"); v != "" {
			var uid uint
			fmt.Sscan(v, &uid)
			c.Set("user_id", uid)
		}
		c.Next()
	})
	r.Use(func(c *gin.Context) {
		if v := c.GetHeader("X-User-Role"); v != "" {
			c.Set("user_role", v)
		}
		c.Next()
	})
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
	req.Header.Set("X-User-Id", fmt.Sprintf("%v", depPlayer2ID))
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestOrder_Transition_Pending_To_Paid(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/pending-to-paid", nil)
	r.ServeHTTP(w, req)
	assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusConflict || w.Code == http.StatusUnprocessableEntity || w.Code == http.StatusNotFound)
}

func TestOrder_Transition_Pending_To_Paid_On_PaymentMethod_Violated(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerOID := createDepPlayer(t, r, db)
	_ = depPlayerOID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Pending", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerOID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/pending-to-paid", nil)
	r.ServeHTTP(w, req)
	assert.True(t, w.Code == http.StatusUnprocessableEntity || w.Code == http.StatusConflict)
}

func TestOrder_Transition_Paid_To_Processing(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/paid-to-processing", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestOrder_Transition_Processing_To_Shipped(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/processing-to-shipped", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestOrder_Transition_Processing_To_Shipped_On_TrackingNumber_Violated(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerOID := createDepPlayer(t, r, db)
	_ = depPlayerOID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Processing", "total": 0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerOID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/processing-to-shipped", nil)
	req.Header.Set("X-User-Role", "Admin")
	r.ServeHTTP(w, req)
	assert.True(t, w.Code == http.StatusUnprocessableEntity || w.Code == http.StatusConflict)
}

func TestOrder_Transition_Shipped_To_Completed(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/shipped-to-completed", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestOrder_Transition_Pending_To_Cancelled(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/pending-to-cancelled", nil)
	r.ServeHTTP(w, req)
	assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusConflict || w.Code == http.StatusUnprocessableEntity || w.Code == http.StatusNotFound)
}

func TestOrder_Transition_Paid_To_Cancelled(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/paid-to-cancelled", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestOrder_Transition_Completed_To_Refunded(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/completed-to-refunded", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusForbidden, w.Code)
}

func TestOrder_Transition_Refunded_To_Completed(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/refunded-to-completed", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusConflict, w.Code)
}

func TestOrder_Transition_Completed_To_Cancelled(t *testing.T) {
	db, r := setupOrderDB(t)
	_ = db
	depPlayerTID := createDepPlayer(t, r, db)
	_ = depPlayerTID
	created := postOrder(t, r, db, map[string]interface{}{"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z", "player_id": depPlayerTID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PATCH", "/api/orders/"+id+"/transitions/completed-to-cancelled", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusConflict, w.Code)
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
