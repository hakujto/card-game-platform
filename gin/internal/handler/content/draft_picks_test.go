package handler_content_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/content"
	model "cards_project/internal/model/content"
)

func setupDraftPickDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewDraftPickHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewDraftSessionHandler(db).RegisterRoutes(r)
	handler_app.NewDraftParticipantHandler(db).RegisterRoutes(r)
	return db, r
}

func TestDraftPick_List(t *testing.T) {
	_, r := setupDraftPickDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/draft_picks", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
