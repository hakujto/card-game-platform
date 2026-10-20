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

func setupTradeBidApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	h := handler_app.NewTradeBidHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewTradeListingHandler(db).RegisterRoutes(app)
	return db, app
}

func postTradeBid(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/trade_bids", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListTradeBid(t *testing.T) {
	_, app := setupTradeBidApp(t)
	req := httptest.NewRequest("GET", "/api/trade_bids", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateTradeBid(t *testing.T) {
	db, app := setupTradeBidApp(t)
	depTradeListingResp := postTradeListing(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"})
	_ = depTradeListingResp
	depTradeListingID := uint(depTradeListingResp["id"].(float64))
	_ = depTradeListingID
	body := map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradeListingID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/trade_bids", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["amount"])
	assert.NotNil(t, result["placed_at"])
	assert.NotNil(t, result["is_winning"])
}

func TestGetTradeBid(t *testing.T) {
	db, app := setupTradeBidApp(t)
	depTradeListingResp := postTradeListing(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"})
	depTradeListingID := uint(depTradeListingResp["id"].(float64))
	_ = depTradeListingID
	created := postTradeBid(t, app, db, map[string]interface{}{"amount": 1, "placed_at": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": depTradeListingID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/trade_bids/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
