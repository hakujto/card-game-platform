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

func setupArticleApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	app := fiber.New()
	app.Use(func(c *fiber.Ctx) error {
		if v := c.Get("X-User-Role"); v != "" {
			c.Locals("user_role", v)
		}
		return c.Next()
	})
	h := handler_app.NewArticleHandler(db)
	h.RegisterRoutes(app)
	return db, app
}

func postArticle(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/articles", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListArticle(t *testing.T) {
	_, app := setupArticleApp(t)
	req := httptest.NewRequest("GET", "/api/articles", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestSearchArticle(t *testing.T) {
	_, app := setupArticleApp(t)
	req := httptest.NewRequest("GET", "/api/articles?q=test", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateArticle(t *testing.T) {
	_, app := setupArticleApp(t)
	body := map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "total_views_alltime": 1, "is_featured": true, "published_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/articles", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	assert.NotNil(t, result["title"])
	assert.NotNil(t, result["slug"])
	assert.NotNil(t, result["body"])
	assert.NotNil(t, result["status"])
	assert.NotNil(t, result["article_type"])
	assert.NotNil(t, result["language"])
	assert.NotNil(t, result["view_count"])
	assert.NotNil(t, result["likes_count"])
	assert.NotNil(t, result["total_views_alltime"])
	assert.NotNil(t, result["is_featured"])
	assert.NotNil(t, result["published_at"])
}

func TestGetArticle(t *testing.T) {
	db, app := setupArticleApp(t)
	created := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "total_views_alltime": 1, "is_featured": true, "published_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/articles/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestUpdateArticle(t *testing.T) {
	db, app := setupArticleApp(t)
	created := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "total_views_alltime": 1, "is_featured": true, "published_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	id := created["id"].(float64)
	updateBody := map[string]interface{}{"title": "test"}
	b, _ := json.Marshal(updateBody)
	req := httptest.NewRequest("PUT", fmt.Sprintf("/api/articles/%v", id), bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}
