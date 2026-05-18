package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradelistingHandler struct { db *gorm.DB }

func NewTradelistingHandler(db *gorm.DB) *TradelistingHandler {
	return &TradelistingHandler{db: db}
}

func (h *TradelistingHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tradelistings")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/trade-listings/{id}/close", h.Close)
	g.PATCH("/:id/api/trade-listings/{id}/extend", h.Extend)
	g.DELETE("/:id/api/trade-listings/{id}/cancel", h.Cancel)
}

func (h *TradelistingHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Tradelisting
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TradelistingResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TradelistingHandler) Create(c *gin.Context) {
	var req model.TradelistingCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTradelisting(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Tradelisting{}
	row.ListingType = req.ListingType
	row.AskingPrice = req.AskingPrice
	row.AuctionStartPrice = req.AuctionStartPrice
	row.AuctionCurrentBid = req.AuctionCurrentBid
	row.AuctionEndTime = req.AuctionEndTime
	row.Foil = req.Foil
	row.Condition = req.Condition
	row.Quantity = req.Quantity
	row.Status = req.Status
	row.Description = req.Description
	row.ExpiresAt = req.ExpiresAt
	row.SellerID = req.SellerID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TradelistingHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradelistingHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	var req model.TradelistingUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTradelisting(&row)
	if msgs := validateTradelisting(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradelistingHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TradelistingHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Tradelisting{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TradelistingHandler) Close(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	err := row.Close()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradelistingHandler) Extend(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	days := func() int {
		v, ok := body["days"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Extend(days)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradelistingHandler) Cancel(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	err := row.Cancel()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradelistingHandler) SetStatus(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var body struct{ Value string `json:"value"` }
	if err := c.ShouldBindJSON(&body); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	var row model.Tradelisting
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tradelisting"); return }
		handler.DbError(c, err); return
	}
	row.Status = model.TradelistingStatusType(body.Value)
	if row.Status == "Sold" {
		_ = row.FinalizeAuction() // @on(status = Sold)
	}
	h.db.Save(&row)
	c.JSON(http.StatusOK, row.ToResponse())
}

func validateTradelisting(req *model.TradelistingCreateRequest) []string {
	var errs []string
	if !((!( req.ListingType == model.TradelistingListingTypeType_FixedPrice ) || (req.AskingPrice != nil))) {
		errs = append(errs, "Fixed price listing must have an asking price")
	}
	if !((!( req.ListingType == model.TradelistingListingTypeType_Auction ) || (req.AuctionStartPrice != nil && req.AuctionEndTime != nil))) {
		errs = append(errs, "Auction listing must have a start price and end time")
	}
	if !((req.Quantity >= 1 && req.Quantity <= 9999)) {
		errs = append(errs, "Listing quantity must be between 1 and 9999")
	}
	return errs
}

func toCreateRequestTradelisting(m *model.Tradelisting) model.TradelistingCreateRequest {
	return model.TradelistingCreateRequest{
		ListingType: m.ListingType,
		AskingPrice: m.AskingPrice,
		AuctionStartPrice: m.AuctionStartPrice,
		AuctionCurrentBid: m.AuctionCurrentBid,
		AuctionEndTime: m.AuctionEndTime,
		Foil: m.Foil,
		Condition: m.Condition,
		Quantity: m.Quantity,
		Status: m.Status,
		Description: m.Description,
		ExpiresAt: m.ExpiresAt,
		SellerID: m.SellerID,
		CardID: m.CardID,
	}
}
