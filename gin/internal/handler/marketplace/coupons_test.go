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

func setupCouponDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewCouponHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postCoupon(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/coupons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestCoupon_List(t *testing.T) {
	_, r := setupCouponDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/coupons", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCoupon_Create(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	body := map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true}
	result := postCoupon(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestCoupon_Get(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	created := postCoupon(t, r, db, map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/coupons/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCoupon_Update(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	created := postCoupon(t, r, db, map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"code": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/coupons/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestCoupon_Delete(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	created := postCoupon(t, r, db, map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/coupons/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestCoupon_Rule_DiscountValuePositive_Violated(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	body := map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 0, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "is_active": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/coupons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCoupon_Rule_PercentDiscountRange_Violated(t *testing.T) {
	db, r := setupCouponDB(t)
	_ = db
	body := map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": "101.00", "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "is_active": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/coupons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
