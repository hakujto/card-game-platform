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

func setupOrderItemApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	h := handler_app.NewOrderItemHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewOrderHandler(db).RegisterRoutes(app)
	handler_app.NewProductHandler(db).RegisterRoutes(app)
	return db, app
}

func postOrderItem(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/order_items", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListOrderItem(t *testing.T) {
	_, app := setupOrderItemApp(t)
	req := httptest.NewRequest("GET", "/api/order_items", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateOrderItem(t *testing.T) {
	db, app := setupOrderItemApp(t)
	depOrderResp := postOrder(t, app, db, map[string]interface{}{"status": "Pending", "total": 0.0, "discount_applied": 0.0, "currency": "AAA", "created_at": "2024-01-01T00:00:00Z"})
	_ = depOrderResp
	depOrderID := uint(depOrderResp["id"].(float64))
	_ = depOrderID
	depProductResp := postProduct(t, app, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 1, "featured": true})
	_ = depProductResp
	depProductID := uint(depProductResp["id"].(float64))
	_ = depProductID
	body := map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrderID, "product_id": depProductID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/order_items", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["quantity"])
	assert.NotNil(t, result["price_at_purchase"])
	assert.NotNil(t, result["foil"])
}

func TestGetOrderItem(t *testing.T) {
	db, app := setupOrderItemApp(t)
	depOrderResp := postOrder(t, app, db, map[string]interface{}{"status": "Pending", "total": 0.0, "discount_applied": 0.0, "currency": "AAA", "created_at": "2024-01-01T00:00:00Z"})
	depOrderID := uint(depOrderResp["id"].(float64))
	_ = depOrderID
	depProductResp := postProduct(t, app, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 1, "featured": true})
	depProductID := uint(depProductResp["id"].(float64))
	_ = depProductID
	created := postOrderItem(t, app, db, map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrderID, "product_id": depProductID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/order_items/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteOrderItem(t *testing.T) {
	db, app := setupOrderItemApp(t)
	depOrderResp := postOrder(t, app, db, map[string]interface{}{"status": "Pending", "total": 0.0, "discount_applied": 0.0, "currency": "AAA", "created_at": "2024-01-01T00:00:00Z"})
	depOrderID := uint(depOrderResp["id"].(float64))
	_ = depOrderID
	depProductResp := postProduct(t, app, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 1, "featured": true})
	depProductID := uint(depProductResp["id"].(float64))
	_ = depProductID
	created := postOrderItem(t, app, db, map[string]interface{}{"quantity": 1, "price_at_purchase": 0, "foil": true, "order_id": depOrderID, "product_id": depProductID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/order_items/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
