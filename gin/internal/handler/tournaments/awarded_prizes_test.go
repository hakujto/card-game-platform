package handler_tournaments_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/tournaments"
	model "cards_project/internal/model/tournaments"
)

func setupAwardedPrizeDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Season{}, &model.Tournament{}, &model.TournamentJudge{}, &model.TournamentRegistration{}, &model.TournamentRound{}, &model.Match{}, &model.Game{}, &model.TournamentPrize{}, &model.AwardedPrize{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewAwardedPrizeHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewSeasonHandler(db).RegisterRoutes(r)
	handler_app.NewTournamentHandler(db).RegisterRoutes(r)
	handler_app.NewTournamentPrizeHandler(db).RegisterRoutes(r)
	return db, r
}

func TestAwardedPrize_List(t *testing.T) {
	_, r := setupAwardedPrizeDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/awarded_prizes", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
