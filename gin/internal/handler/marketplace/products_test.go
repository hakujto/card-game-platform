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

func setupProductDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewProductHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postProduct(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestProduct_List(t *testing.T) {
	_, r := setupProductDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/products", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestProduct_Create(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true}
	result := postProduct(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestProduct_Get(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	created := postProduct(t, r, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/products/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestProduct_Update(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	created := postProduct(t, r, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/products/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestProduct_Delete(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	created := postProduct(t, r, db, map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": true, "discount_percent": 1, "featured": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/products/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}

func TestProduct_Rule_PricePositive_Violated(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0, "stock": 1, "active": true, "discount_percent": 1, "featured": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestProduct_Rule_StockNotNegative_Violated(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": -1, "active": true, "discount_percent": 1, "featured": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestProduct_Rule_DiscountPercentRange_Violated(t *testing.T) {
	db, r := setupProductDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 101, "featured": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
