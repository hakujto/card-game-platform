package handler_content_test

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

	handler_app "cards_project/internal/handler/content"
	model "cards_project/internal/model/content"
)

func setupArticleTagAssignmentDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.DraftSession{}, &model.DraftParticipant{}, &model.DraftPick{}, &model.Article{}, &model.ArticleTag{}, &model.ArticleTagAssignment{}, &model.ArticleComment{}, &model.Stream{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewArticleTagAssignmentHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postArticleTagAssignment(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/article_tag_assignments", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestArticleTagAssignment_List(t *testing.T) {
	_, r := setupArticleTagAssignmentDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/article_tag_assignments", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestArticleTagAssignment_Create(t *testing.T) {
	db, r := setupArticleTagAssignmentDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	depArticle1ID := createDepArticle(t, r, db)
	_ = depArticle1ID
	depArticleTag1ID := createDepArticleTag(t, r, db)
	_ = depArticleTag1ID
	body := map[string]interface{}{"article_id": depArticle1ID, "tag_id": depArticleTag1ID}
	result := postArticleTagAssignment(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestArticleTagAssignment_Get(t *testing.T) {
	db, r := setupArticleTagAssignmentDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	depArticle2ID := createDepArticle(t, r, db)
	_ = depArticle2ID
	depArticleTag2ID := createDepArticleTag(t, r, db)
	_ = depArticleTag2ID
	created := postArticleTagAssignment(t, r, db, map[string]interface{}{"article_id": depArticle2ID, "tag_id": depArticleTag2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/article_tag_assignments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestArticleTagAssignment_Update(t *testing.T) {
	db, r := setupArticleTagAssignmentDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	depArticle3ID := createDepArticle(t, r, db)
	_ = depArticle3ID
	depArticleTag3ID := createDepArticleTag(t, r, db)
	_ = depArticleTag3ID
	created := postArticleTagAssignment(t, r, db, map[string]interface{}{"article_id": depArticle3ID, "tag_id": depArticleTag3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"name": "updated"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/article_tag_assignments/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestArticleTagAssignment_Delete(t *testing.T) {
	db, r := setupArticleTagAssignmentDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	depArticle4ID := createDepArticle(t, r, db)
	_ = depArticle4ID
	depArticleTag4ID := createDepArticleTag(t, r, db)
	_ = depArticleTag4ID
	created := postArticleTagAssignment(t, r, db, map[string]interface{}{"article_id": depArticle4ID, "tag_id": depArticleTag4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/article_tag_assignments/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
