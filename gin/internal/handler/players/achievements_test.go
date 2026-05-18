package handler_players_test

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

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupAchievementDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewAchievementHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postAchievement(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/achievements", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestAchievement_List(t *testing.T) {
	_, r := setupAchievementDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/achievements", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAchievement_Create(t *testing.T) {
	db, r := setupAchievementDB(t)
	_ = db
	body := map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true}
	result := postAchievement(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestAchievement_Get(t *testing.T) {
	db, r := setupAchievementDB(t)
	_ = db
	created := postAchievement(t, r, db, map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/achievements/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAchievement_Update(t *testing.T) {
	db, r := setupAchievementDB(t)
	_ = db
	created := postAchievement(t, r, db, map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "test"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/achievements/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestAchievement_Delete(t *testing.T) {
	db, r := setupAchievementDB(t)
	_ = db
	created := postAchievement(t, r, db, map[string]interface{}{"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": true})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/achievements/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
