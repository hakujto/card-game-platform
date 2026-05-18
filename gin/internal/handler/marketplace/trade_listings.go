package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeListingHandler struct { db *gorm.DB }

func NewTradeListingHandler(db *gorm.DB) *TradeListingHandler {
	return &TradeListingHandler{db: db}
}

func (h *TradeListingHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/trade_listings")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/trade-listings/{id}/close", h.Close)
	g.PATCH("/:id/api/trade-listings/{id}/extend", h.Extend)
	g.DELETE("/:id/api/trade-listings/{id}/cancel", h.Cancel)
	g.GET("/:id/api/trade-listings/{id}/expired", h.IsExpired)
	g.POST("/:id/api/trade-listings/{id}/finalize", h.FinalizeAuction)
}

func (h *TradeListingHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeListing
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TradeListingResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TradeListingHandler) Create(c *gin.Context) {
	var req model.TradeListingCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTradeListing(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.TradeListing{}
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

func (h *TradeListingHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeListingHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	var req model.TradeListingUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTradeListing(&row)
	if msgs := validateTradeListing(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TradeListingHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TradeListingHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TradeListing{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TradeListingHandler) Close(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	err := row.Close()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeListingHandler) Extend(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
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

func (h *TradeListingHandler) Cancel(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	err := row.Cancel()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeListingHandler) IsExpired(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsExpired()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *TradeListingHandler) FinalizeAuction(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	err := row.FinalizeAuction()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TradeListingHandler) SetStatus(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var body struct{ Value string `json:"value"` }
	if err := c.ShouldBindJSON(&body); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TradeListing"); return }
		handler.DbError(c, err); return
	}
	row.Status = model.TradeListingStatusType(body.Value)
	if row.Status == "Sold" {
		_ = row.FinalizeAuction() // @on(status = Sold)
	}
	h.db.Save(&row)
	c.JSON(http.StatusOK, row.ToResponse())
}

func validateTradeListing(req *model.TradeListingCreateRequest) []string {
	var errs []string
	if !((!( req.ListingType == model.TradeListingListingTypeType_FixedPrice ) || (req.AskingPrice != nil))) {
		errs = append(errs, "Fixed price listing must have an asking price")
	}
	if !((!( req.ListingType == model.TradeListingListingTypeType_Auction ) || (req.AuctionStartPrice != nil && req.AuctionEndTime != nil))) {
		errs = append(errs, "Auction listing must have a start price and end time")
	}
	if !((req.Quantity >= 1 && req.Quantity <= 9999)) {
		errs = append(errs, "Listing quantity must be between 1 and 9999")
	}
	return errs
}

func toCreateRequestTradeListing(m *model.TradeListing) model.TradeListingCreateRequest {
	return model.TradeListingCreateRequest{
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
