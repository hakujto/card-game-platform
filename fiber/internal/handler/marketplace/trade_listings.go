package handler_marketplace

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type TradeListingHandler struct { db *gorm.DB }

func NewTradeListingHandler(db *gorm.DB) *TradeListingHandler {
	return &TradeListingHandler{db: db}
}

func (h *TradeListingHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/trade_listings")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/close", h.Close)
	g.Patch("/:id/extend", h.Extend)
	g.Delete("/:id/cancel", h.Cancel)
	g.Get("/:id/expired", h.IsExpired)
	g.Post("/:id/finalize", h.FinalizeAuction)
	g.Patch("/:id/transitions/pending-to-active", h.TransitionPendingToActive)
	g.Patch("/:id/transitions/active-to-sold", h.TransitionActiveToSold)
	g.Patch("/:id/transitions/active-to-expired", h.TransitionActiveToExpired)
	g.Patch("/:id/transitions/active-to-cancelled", h.TransitionActiveToCancelled)
	g.Patch("/:id/transitions/sold-to-active", h.TransitionSoldToActive)
	g.Patch("/:id/transitions/expired-to-active", h.TransitionExpiredToActive)
}

func (h *TradeListingHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TradeListing
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("description LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TradeListingResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TradeListingHandler) Create(c *fiber.Ctx) error {
	var req model.TradeListingCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTradeListing(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TradeListing{}
	row.PublicId = req.PublicId
	row.Status = req.Status
	row.ListingType = req.ListingType
	row.AskingPrice = req.AskingPrice
	row.AuctionStartPrice = req.AuctionStartPrice
	row.AuctionCurrentBid = req.AuctionCurrentBid
	row.AuctionEndTime = req.AuctionEndTime
	row.Foil = req.Foil
	row.Condition = req.Condition
	row.Quantity = req.Quantity
	row.Description = req.Description
	row.ExpiresAt = req.ExpiresAt
	row.SellerID = req.SellerID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TradeListingHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	var req model.TradeListingUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) Close(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	err := row.Close()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeListingHandler) Extend(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	days := func() int {
		v, ok := body["days"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Extend(days)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeListingHandler) Cancel(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	if !(row.Status == model.TradeListingStatusType_Active) {
		return handler.UnprocessableError(c, "Guard condition not met for cancel")
	}
	err := row.Cancel()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeListingHandler) IsExpired(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	result, err := row.IsExpired()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *TradeListingHandler) FinalizeAuction(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesFinalizeAuction := []string{"admin", "seller"}
	roleOkFinalizeAuction := false
	for _, r := range allowedRolesFinalizeAuction { if r == userRole { roleOkFinalizeAuction = true; break } }
	if !roleOkFinalizeAuction { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for finalize_auction"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	err := row.FinalizeAuction()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TradeListingHandler) SetStatus(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var body struct{ Value string `json:"value"` }
	if err := c.BodyParser(&body); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	row.Status = model.TradeListingStatusType(body.Value)
	if row.Status == "Sold" {
		_ = row.FinalizeAuction() // @on(status = Sold)
	}
	h.db.Save(&row)
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) TransitionPendingToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPendingToActive := []string{"Seller"}
	roleOkTransitionPendingToActive := false
	for _, r := range allowedRolesTransitionPendingToActive { if r == userRole { roleOkTransitionPendingToActive = true; break } }
	if !roleOkTransitionPendingToActive { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Pending -> Active"}) }
	if err := row.AssertTransition("Active"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.Quantity == 0 {
		return handler.UnprocessableError(c, "quantity is required for this transition")
	}
	row.Status = model.TradeListingStatusType_Active
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) TransitionActiveToSold(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Sold"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TradeListingStatusType_Sold
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.FinalizeAuction() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) TransitionActiveToExpired(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	if err := row.AssertTransition("Expired"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TradeListingStatusType_Expired
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Close() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) TransitionActiveToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionActiveToCancelled := []string{"Seller", "Admin"}
	roleOkTransitionActiveToCancelled := false
	for _, r := range allowedRolesTransitionActiveToCancelled { if r == userRole { roleOkTransitionActiveToCancelled = true; break } }
	if !roleOkTransitionActiveToCancelled { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Active -> Cancelled"}) }
	if err := row.AssertTransition("Cancelled"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TradeListingStatusType_Cancelled
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Cancel() // @after
	return c.JSON(row.ToResponse())
}

func (h *TradeListingHandler) TransitionSoldToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Sold -> Active is not allowed")
}

func (h *TradeListingHandler) TransitionExpiredToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TradeListing
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TradeListing") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Expired -> Active is not allowed")
}

// ── Validation rules ─────────────────────────────────────────────
func validateTradeListing(req *model.TradeListingCreateRequest) []string {
	var errs []string
	if (req.ListingType == model.TradeListingListingTypeType_FixedPrice) && req.AskingPrice == nil {
		errs = append(errs, "asking_price is required")
	}
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
		PublicId: m.PublicId,
		Status: m.Status,
		ListingType: m.ListingType,
		AskingPrice: m.AskingPrice,
		AuctionStartPrice: m.AuctionStartPrice,
		AuctionCurrentBid: m.AuctionCurrentBid,
		AuctionEndTime: m.AuctionEndTime,
		Foil: m.Foil,
		Condition: m.Condition,
		Quantity: m.Quantity,
		Description: m.Description,
		ExpiresAt: m.ExpiresAt,
		SellerID: m.SellerID,
		CardID: m.CardID,
	}
}
