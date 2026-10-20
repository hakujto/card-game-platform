package handler_cards_test

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

	handler_app "cards_project/internal/handler/cards"
	model "cards_project/internal/model/cards"
)

func setupCardRulingApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Card{}, &model.CardSet{}, &model.CardRuling{}, &model.CardAbility{}, &model.Deck{}, &model.DeckCard{}, &model.DeckSideboardCard{}, &model.DeckTag{}, &model.DeckTagAssignment{})
	app := fiber.New()
	h := handler_app.NewCardRulingHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewCardSetHandler(db).RegisterRoutes(app)
	handler_app.NewCardHandler(db).RegisterRoutes(app)
	return db, app
}

func postCardRuling(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/card_rulings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCardRuling(t *testing.T) {
	_, app := setupCardRulingApp(t)
	req := httptest.NewRequest("GET", "/api/card_rulings", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCardRuling(t *testing.T) {
	db, app := setupCardRulingApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	_ = depCardSetResp
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	_ = depCardResp
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	body := map[string]interface{}{"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": depCardID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/card_rulings", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["ruling_text"])
	assert.NotNil(t, result["published_at"])
	assert.NotNil(t, result["source"])
}

func TestGetCardRuling(t *testing.T) {
	db, app := setupCardRulingApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	created := postCardRuling(t, app, db, map[string]interface{}{"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": depCardID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/card_rulings/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteCardRuling(t *testing.T) {
	db, app := setupCardRulingApp(t)
	depCardSetResp := postCardSet(t, app, db, map[string]interface{}{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": true})
	depCardSetID := uint(depCardSetResp["id"].(float64))
	_ = depCardSetID
	depCardResp := postCard(t, app, db, map[string]interface{}{"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": []interface{}{"White"}, "description": "test", "legal_formats": []interface{}{"Standard"}, "is_banned": true, "is_restricted": true, "power_level": 1, "total_copies_in_circulation": 1, "set_id": depCardSetID})
	depCardID := uint(depCardResp["id"].(float64))
	_ = depCardID
	created := postCardRuling(t, app, db, map[string]interface{}{"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": depCardID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/card_rulings/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
