package handler_content_test

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

	handler_app "cards_project/internal/handler/content"
	model "cards_project/internal/model/content"
)

func setupArticleCommentApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	app := fiber.New()
	h := handler_app.NewArticleCommentHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewArticleHandler(db).RegisterRoutes(app)
	return db, app
}

func postArticleComment(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/article_comments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListArticleComment(t *testing.T) {
	_, app := setupArticleCommentApp(t)
	req := httptest.NewRequest("GET", "/api/article_comments", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateArticleComment(t *testing.T) {
	db, app := setupArticleCommentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	_ = depArticleResp
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	body := map[string]interface{}{"body": "test", "is_hidden": true, "created_at": "2024-01-01T00:00:00Z", "article_id": depArticleID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/article_comments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["body"])
	assert.NotNil(t, result["is_hidden"])
}

func TestGetArticleComment(t *testing.T) {
	db, app := setupArticleCommentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	created := postArticleComment(t, app, db, map[string]interface{}{"body": "test", "is_hidden": true, "created_at": "2024-01-01T00:00:00Z", "article_id": depArticleID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/article_comments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteArticleComment(t *testing.T) {
	db, app := setupArticleCommentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	created := postArticleComment(t, app, db, map[string]interface{}{"body": "test", "is_hidden": true, "created_at": "2024-01-01T00:00:00Z", "article_id": depArticleID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/article_comments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
