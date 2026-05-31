package handler_players_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/players"
	model "cards_project/internal/model/players"
)

func setupPlayerAchievementDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewPlayerAchievementHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewPlayerHandler(db).RegisterRoutes(r)
	handler_app.NewAchievementHandler(db).RegisterRoutes(r)
	return db, r
}

func TestPlayerAchievement_List(t *testing.T) {
	_, r := setupPlayerAchievementDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/player_achievements", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
