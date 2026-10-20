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

func setupTradeListingApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Role"); v != "" {
			c.Locals("user_role", v)
		}
		return c.Next()
	})
	h := handler_app.NewTradeListingHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postTradeListing(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/trade_listings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListTradeListing(t *testing.T) {
	_, app := setupTradeListingApp(t)
	req := httptest.NewRequest("GET", "/api/trade_listings", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchTradeListing(t *testing.T) {
	_, app := setupTradeListingApp(t)
	req := httptest.NewRequest("GET", "/api/trade_listings?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateTradeListing(t *testing.T) {
	_, app := setupTradeListingApp(t)
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/trade_listings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["public_id"])
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["listing_type"])
	assert.NotNil(t, result["asking_price"])
	assert.NotNil(t, result["auction_start_price"])
	assert.NotNil(t, result["auction_end_time"])
	assert.NotNil(t, result["foil"])
	assert.NotNil(t, result["condition"])
	assert.NotNil(t, result["quantity"])
}

func TestGetTradeListing(t *testing.T) {
	db, app := setupTradeListingApp(t)
	created := postTradeListing(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/trade_listings/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateTradeListing(t *testing.T) {
	db, app := setupTradeListingApp(t)
	created := postTradeListing(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00Z", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PATCH", fmt.Sprintf("/api/trade_listings/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
