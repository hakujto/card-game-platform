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

func setupArticleTagAssignmentApp(t *testing.T) (*gorm.DB, *fiber.App) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	app := fiber.New()
	h := handler_app.NewArticleTagAssignmentHandler(db)
	h.RegisterRoutes(app)
	handler_app.NewArticleHandler(db).RegisterRoutes(app)
	handler_app.NewArticleTagHandler(db).RegisterRoutes(app)
	return db, app
}

func postArticleTagAssignment(t *testing.T, app *fiber.App, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/article_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return result
}

func TestListArticleTagAssignment(t *testing.T) {
	_, app := setupArticleTagAssignmentApp(t)
	req := httptest.NewRequest("GET", "/api/article_tag_assignments", nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestCreateArticleTagAssignment(t *testing.T) {
	db, app := setupArticleTagAssignmentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	_ = depArticleResp
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	depArticleTagResp := postArticleTag(t, app, db, map[string]interface{}{"name": "test", "slug": "test"})
	_ = depArticleTagResp
	depArticleTagID := uint(depArticleTagResp["id"].(float64))
	_ = depArticleTagID
	body := map[string]interface{}{"article_id": depArticleID, "tag_id": depArticleTagID}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/article_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, resp.StatusCode)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
}

func TestGetArticleTagAssignment(t *testing.T) {
	db, app := setupArticleTagAssignmentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	depArticleTagResp := postArticleTag(t, app, db, map[string]interface{}{"name": "test", "slug": "test"})
	depArticleTagID := uint(depArticleTagResp["id"].(float64))
	_ = depArticleTagID
	created := postArticleTagAssignment(t, app, db, map[string]interface{}{"article_id": depArticleID, "tag_id": depArticleTagID})
	id := created["id"].(float64)
	req := httptest.NewRequest("GET", fmt.Sprintf("/api/article_tag_assignments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestDeleteArticleTagAssignment(t *testing.T) {
	db, app := setupArticleTagAssignmentApp(t)
	depArticleResp := postArticle(t, app, db, map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"})
	depArticleID := uint(depArticleResp["id"].(float64))
	_ = depArticleID
	depArticleTagResp := postArticleTag(t, app, db, map[string]interface{}{"name": "test", "slug": "test"})
	depArticleTagID := uint(depArticleTagResp["id"].(float64))
	_ = depArticleTagID
	created := postArticleTagAssignment(t, app, db, map[string]interface{}{"article_id": depArticleID, "tag_id": depArticleTagID})
	id := created["id"].(float64)
	req := httptest.NewRequest("DELETE", fmt.Sprintf("/api/article_tag_assignments/%v", id), nil)
	resp, err := app.Test(req, -1)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusNoContent, resp.StatusCode)
}
