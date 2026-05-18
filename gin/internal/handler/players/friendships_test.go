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

func setupFriendshipDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Player{}, &model.PlayerSeasonStats{}, &model.PlayerCollection{}, &model.Friendship{}, &model.Achievement{}, &model.PlayerAchievement{}, &model.CraftingRecipe{}, &model.CraftingIngredient{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewFriendshipHandler(db)
	h.RegisterRoutes(r)
	return db, r
}

func postFriendship(t *testing.T, r *gin.Engine, db *gorm.DB, body map[string]interface{}) map[string]interface{} {
	b, _ := json.Marshal(body)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/friendships", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	var result map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &result)
	return result
}

func TestFriendship_List(t *testing.T) {
	_, r := setupFriendshipDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/friendships", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestFriendship_Create(t *testing.T) {
	db, r := setupFriendshipDB(t)
	_ = db
	depPlayer1ID := createDepPlayer(t, r, db)
	_ = depPlayer1ID
	body := map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayer1ID, "receiver_id": depPlayer1ID}
	result := postFriendship(t, r, db, body)
	assert.NotNil(t, result["id"])
}

func TestFriendship_Get(t *testing.T) {
	db, r := setupFriendshipDB(t)
	_ = db
	depPlayer2ID := createDepPlayer(t, r, db)
	_ = depPlayer2ID
	created := postFriendship(t, r, db, map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayer2ID, "receiver_id": depPlayer2ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/friendships/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestFriendship_Update(t *testing.T) {
	db, r := setupFriendshipDB(t)
	_ = db
	depPlayer3ID := createDepPlayer(t, r, db)
	_ = depPlayer3ID
	created := postFriendship(t, r, db, map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayer3ID, "receiver_id": depPlayer3ID})
	id := fmt.Sprintf("%v", created["id"])
	upBody := map[string]interface{}{"created_at": "2024-01-01T00:00:00Z"}
	b, _ := json.Marshal(upBody)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/api/friendships/"+id, bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestFriendship_Delete(t *testing.T) {
	db, r := setupFriendshipDB(t)
	_ = db
	depPlayer4ID := createDepPlayer(t, r, db)
	_ = depPlayer4ID
	created := postFriendship(t, r, db, map[string]interface{}{"status": "Pending", "created_at": "2024-01-01T00:00:00Z", "requester_id": depPlayer4ID, "receiver_id": depPlayer4ID})
	id := fmt.Sprintf("%v", created["id"])
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/api/friendships/"+id, nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusNoContent, w.Code)
}
