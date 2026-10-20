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

func setupOrderApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Id"); v != "" {
			var uid uint
			fmt.Sscan(v, &uid)
			c.Locals("user_id", uid)
		}
		return c.Next()
	})
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Role"); v != "" {
			c.Locals("user_role", v)
		}
		return c.Next()
	})
	h := handler_app.NewOrderHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postOrder(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListOrder(t *testing.T) {
	_, app := setupOrderApp(t)
	req := httptest.NewRequest("GET", "/api/orders", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateOrder(t *testing.T) {
	_, app := setupOrderApp(t)
	body := map[string]interface{}{"status": "Shipped", "total": 29.99, "discount_applied": 0.0, "currency": "USD", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["total"])
	assert.NotNil(t, result["discount_applied"])
	assert.NotNil(t, result["currency"])
	assert.NotNil(t, result["tracking_number"])
	assert.NotNil(t, result["paid_at"])
}

func TestGetOrder(t *testing.T) {
	db, app := setupOrderApp(t)
	created := postOrder(t, app, db, map[string]interface{}{"status": "Shipped", "total": 29.99, "discount_applied": 0.0, "currency": "USD", "tracking_number": "test", "created_at": "2024-01-01T00:00:00Z", "paid_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/orders/%v", id), nil)
	req.Header.Set("X-User-Id", "1")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
