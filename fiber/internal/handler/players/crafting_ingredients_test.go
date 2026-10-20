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

func setupCraftingIngredientApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	app := fiber.New()
	h := handler_app.NewCraftingIngredientHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewCraftingRecipeHandler(db).RegisterRoutes(app)
	return db, app
}

func postCraftingIngredient(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/crafting_ingredients", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListCraftingIngredient(t *testing.T) {
	_, app := setupCraftingIngredientApp(t)
	req := httptest.NewRequest("GET", "/api/crafting_ingredients", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateCraftingIngredient(t *testing.T) {
	db, app := setupCraftingIngredientApp(t)
	depCraftingRecipeResp := postCraftingRecipe(t, app, db, map[string]interface{}{"dust_cost": 1, "is_available": true})
	_ = depCraftingRecipeResp
	depCraftingRecipeID := uint(depCraftingRecipeResp["id"].(float64))
	_ = depCraftingRecipeID
	body := map[string]interface{}{"quantity": 1, "recipe_id": depCraftingRecipeID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/crafting_ingredients", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["quantity"])
}

func TestGetCraftingIngredient(t *testing.T) {
	db, app := setupCraftingIngredientApp(t)
	depCraftingRecipeResp := postCraftingRecipe(t, app, db, map[string]interface{}{"dust_cost": 1, "is_available": true})
	depCraftingRecipeID := uint(depCraftingRecipeResp["id"].(float64))
	_ = depCraftingRecipeID
	created := postCraftingIngredient(t, app, db, map[string]interface{}{"quantity": 1, "recipe_id": depCraftingRecipeID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/crafting_ingredients/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteCraftingIngredient(t *testing.T) {
	db, app := setupCraftingIngredientApp(t)
	depCraftingRecipeResp := postCraftingRecipe(t, app, db, map[string]interface{}{"dust_cost": 1, "is_available": true})
	depCraftingRecipeID := uint(depCraftingRecipeResp["id"].(float64))
	_ = depCraftingRecipeID
	created := postCraftingIngredient(t, app, db, map[string]interface{}{"quantity": 1, "recipe_id": depCraftingRecipeID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/crafting_ingredients/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
