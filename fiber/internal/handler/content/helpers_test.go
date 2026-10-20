package handler_content_test

import (
	"encoding/json"
	"net/http/httptest"
	"bytes"
	"testing"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)
func createDepDraftSession(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 1, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_sessions", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepDraftParticipant(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"seat_number": 1, "joined_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/draft_participants", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepArticle(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/articles", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}

func createDepArticleTag(t *testing.T, app *fiber.App, db *gorm.DB) uint {
	body := map[string]interface{}{"name": "test", "slug": "test"}
	b, _ := json.Marshal(body)
	req := httptest.NewRequest("POST", "/api/article_tags", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req, -1)
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	return uint(result["id"].(float64))
}
