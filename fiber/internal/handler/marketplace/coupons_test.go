package handler_marketplace_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"bytes"
	"fmt"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/marketplace"
	model "cards_project/internal/model/marketplace"
)

func setupCouponApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	h := handler_app.NewCouponHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postCoupon(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/coupons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCoupon(t *testing.T) {
	_, app := setupCouponApp(t)
	req := httptest.NewRequest("GET", "/api/coupons", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchCoupon(t *testing.T) {
	_, app := setupCouponApp(t)
	req := httptest.NewRequest("GET", "/api/coupons?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCoupon(t *testing.T) {
	_, app := setupCouponApp(t)
	body := map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/coupons", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["code"])
	assert.NotNil(t, result["discount_type"])
	assert.NotNil(t, result["discount_value"])
	assert.NotNil(t, result["min_order_value"])
	assert.NotNil(t, result["valid_from"])
	assert.NotNil(t, result["valid_until"])
	assert.NotNil(t, result["is_active"])
}

func TestGetCoupon(t *testing.T) {
	db, app := setupCouponApp(t)
	created := postCoupon(t, app, db, map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/coupons/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateCoupon(t *testing.T) {
	db, app := setupCouponApp(t)
	created := postCoupon(t, app, db, map[string]interface{}{"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 1, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:01Z", "is_active": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"code": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/coupons/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
