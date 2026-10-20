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

func setupProductApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	app := fiber.New()
	h := handler_app.NewProductHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postProduct(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListProduct(t *testing.T) {
	_, app := setupProductApp(t)
	req := httptest.NewRequest("GET", "/api/products", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchProduct(t *testing.T) {
	_, app := setupProductApp(t)
	req := httptest.NewRequest("GET", "/api/products?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateProduct(t *testing.T) {
	_, app := setupProductApp(t)
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["name"])
	assert.NotNil(t, result["product_type"])
	assert.NotNil(t, result["price"])
	assert.NotNil(t, result["stock"])
	assert.NotNil(t, result["active"])
	assert.NotNil(t, result["discount_percent"])
	assert.NotNil(t, result["featured"])
}

func TestGetProduct(t *testing.T) {
	db, app := setupProductApp(t)
	created := postProduct(t, app, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/products/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateProduct(t *testing.T) {
	db, app := setupProductApp(t)
	created := postProduct(t, app, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/products/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
