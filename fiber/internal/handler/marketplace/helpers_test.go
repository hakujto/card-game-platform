package handler_marketplace_test

import (
	"encoding/json"
	"net/http/httptest"
	"bytes"
	"testing"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)
func createDepOrder(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"status": "Pending", "total": 0.0, "discount_applied": 0.0, "currency": "AAA", "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepProduct(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 1, "featured": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepTradeListing(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "status": "Active", "listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 1, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/trade_listings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}
