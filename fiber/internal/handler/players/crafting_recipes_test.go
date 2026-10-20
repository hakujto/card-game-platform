package handler_players_test

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

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupCraftingRecipeApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	app := fiber.New()
	h := handler_app.NewCraftingRecipeHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postCraftingRecipe(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/crafting_recipes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCraftingRecipe(t *testing.T) {
	_, app := setupCraftingRecipeApp(t)
	req := httptest.NewRequest("GET", "/api/crafting_recipes", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCraftingRecipe(t *testing.T) {
	_, app := setupCraftingRecipeApp(t)
	body := map[string]interface{}{"dust_cost": 1, "is_available": true}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/crafting_recipes", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["dust_cost"])
	assert.NotNil(t, result["is_available"])
}

func TestGetCraftingRecipe(t *testing.T) {
	db, app := setupCraftingRecipeApp(t)
	created := postCraftingRecipe(t, app, db, map[string]interface{}{"dust_cost": 1, "is_available": true})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/crafting_recipes/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateCraftingRecipe(t *testing.T) {
	db, app := setupCraftingRecipeApp(t)
	created := postCraftingRecipe(t, app, db, map[string]interface{}{"dust_cost": 1, "is_available": true})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"dust_cost": 1}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/crafting_recipes/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
