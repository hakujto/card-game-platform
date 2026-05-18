package handler_marketplace_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func createDepPlayer(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"display_name": "test", "rank": "Bronze", "rating": 1, "peak_rating": 1, "is_verified": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/players", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepOrder(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"status": "Pending", "total": 0.0, "discount_applied": 0.0, "currency": "xxx", "player_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/orders", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepProduct(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "product_type": "SingleCard", "price": 0.0, "stock": 1, "active": true, "discount_percent": 1, "featured": true}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/products", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepCardSet(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/card_sets", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepCard(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/cards", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepTradelisting(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"listing_type": "FixedPrice", "foil": true, "condition": "Mint", "quantity": 1, "status": "Active", "seller_id": 1, "card_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/tradelistings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}

func createDepTradeTransaction(t *testing.T, r *gin.Engine, db *gorm.DB) uint {
	_ = db
	body := map[string]interface{}{"final_price": 0.0, "platform_fee": 0.0, "status": "Pending", "listing_id": 1, "buyer_id": 1, "seller_id": 1}
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/trade_transactions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	id, _ := result["id"].(float64)
	return uint(id)
}
