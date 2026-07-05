package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeTransactionHandler struct { db *gorm.DB }

func NewTradeTransactionHandler(db *gorm.DB) *TradeTransactionHandler {
	return &TradeTransactionHandler{db: db}
}

func (h *TradeTransactionHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/trade_transactions")
	g.GET("", h.List)
	g.GET("/:id", h.Get)
	g.POST("/:id/api/transactions/{id}/complete", h.Complete)
	g.POST("/:id/api/transactions/{id}/refund", h.Refund)
	g.POST("/:id/api/transactions/{id}/dispute", h.OpenDispute)
	g.GET("/:id/api/transactions/{id}/seller-net", h.SellerNet)
}

func (h *TradeTransactionHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeTransaction
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TradeTransactionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TradeTransactionHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeTransaction"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeTransactionHandler) Complete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeTransaction"); return }
		handler.DbError(c, err); return
	}
	err := row.Complete()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeTransactionHandler) Refund(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeTransaction"); return }
		handler.DbError(c, err); return
	}
	err := row.Refund()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeTransactionHandler) OpenDispute(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeTransaction"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	reason := func() string {
		v, ok := body["reason"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.OpenDispute(reason)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeTransactionHandler) SellerNet(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeTransaction
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeTransaction"); return }
		handler.DbError(c, err); return
	}
	result, err := row.SellerNet()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateTradeTransaction(req *model.TradeTransactionCreateRequest) []string {
	var errs []string
	if (req.Status == model.TradeTransactionStatusType_Completed) && req.CompletedAt == nil {
		errs = append(errs, "completed_at is required")
	}
	if !(float64(req.PlatformFee) <= float64(req.FinalPrice)) {
		errs = append(errs, "Platform fee cannot exceed the final price")
	}
	if !(float64(req.PlatformFee) >= 0) {
		errs = append(errs, "Platform fee must not be negative")
	}
	if !(float64(req.FinalPrice) > 0) {
		errs = append(errs, "Transaction final price must be greater than zero")
	}
	if !((!( req.Status == model.TradeTransactionStatusType_Completed ) || (req.CompletedAt != nil))) {
		errs = append(errs, "Completed transaction must have a completed_at timestamp")
	}
	return errs
}

func toCreateRequestTradeTransaction(m *model.TradeTransaction) model.TradeTransactionCreateRequest {
	return model.TradeTransactionCreateRequest{
		FinalPrice: m.FinalPrice,
		PlatformFee: m.PlatformFee,
		Status: m.Status,
		CompletedAt: m.CompletedAt,
		ListingID: m.ListingID,
		BuyerID: m.BuyerID,
		SellerID: m.SellerID,
	}
}
