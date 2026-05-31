package handler_marketplace_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	handler_app "cards_project/internal/handler/marketplace"
	model "cards_project/internal/model/marketplace"
)

func setupTradeTransactionDB(t *testing.T) (*gorm.DB, *gin.Engine) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	assert.NoError(t, err)
	db.AutoMigrate(&model.Product{}, &model.Order{}, &model.OrderItem{}, &model.Coupon{}, &model.TradeListing{}, &model.TradeBid{}, &model.TradeTransaction{}, &model.CardPriceHistory{}, &model.TradeDispute{})
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := handler_app.NewTradeTransactionHandler(db)
	h.RegisterRoutes(r)
	handler_app.NewTradeListingHandler(db).RegisterRoutes(r)
	return db, r
}

func TestTradeTransaction_List(t *testing.T) {
	_, r := setupTradeTransactionDB(t)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/trade_transactions", nil)
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
}
