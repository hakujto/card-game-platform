package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeBidHandler struct { db *gorm.DB }

func NewTradeBidHandler(db *gorm.DB) *TradeBidHandler {
	return &TradeBidHandler{db: db}
}

func (h *TradeBidHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/trade_bids")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/bids/{id}/outbid", h.OutbidBy)
	g.DELETE("/:id/api/bids/{id}", h.Retract)
}

func (h *TradeBidHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeBid
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TradeBidResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TradeBidHandler) Create(c *gin.Context) {
	var req model.TradeBidCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTradeBid(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.TradeBid{}
	row.Amount = req.Amount
	row.PlacedAt = req.PlacedAt
	row.IsWinning = req.IsWinning
	row.ListingID = req.ListingID
	row.BidderID = req.BidderID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TradeBidHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeBid"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeBidHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeBid"); return }
		handler.DbError(c, err); return
	}
	var req model.TradeBidUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTradeBid(&row)
	if msgs := validateTradeBid(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeBidHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TradeBidHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TradeBid{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeBid"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TradeBidHandler) OutbidBy(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeBid"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	newAmount := func() float64 {
		v, ok := body["new_amount"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return f
	}()
	result, err := row.OutbidBy(newAmount)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *TradeBidHandler) Retract(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeBid
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeBid"); return }
		handler.DbError(c, err); return
	}
	err := row.Retract()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateTradeBid(req *model.TradeBidCreateRequest) []string {
	var errs []string
	if !(float64(req.Amount) > 0) {
		errs = append(errs, "Bid amount must be greater than zero")
	}
	return errs
}

func toCreateRequestTradeBid(m *model.TradeBid) model.TradeBidCreateRequest {
	return model.TradeBidCreateRequest{
		Amount: m.Amount,
		PlacedAt: m.PlacedAt,
		IsWinning: m.IsWinning,
		ListingID: m.ListingID,
		BidderID: m.BidderID,
	}
}
