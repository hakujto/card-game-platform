package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckCardHandler struct { db *gorm.DB }

func NewDeckCardHandler(db *gorm.DB) *DeckCardHandler {
	return &DeckCardHandler{db: db}
}

func (h *DeckCardHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/deck_cards")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Patch("/:id/increment", h.Increment)
	g.Patch("/:id/decrement", h.Decrement)
}

func (h *DeckCardHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckCard
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DeckCardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DeckCardHandler) Create(c *fiber.Ctx) error {
	var req model.DeckCardCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateDeckCard(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.DeckCard{}
	row.Quantity = req.Quantity
	row.IsCommander = req.IsCommander
	row.DeckID = req.DeckID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DeckCardHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckCard") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DeckCardHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckCard") }
		return handler.DbError(c, err)
	}
	var req model.DeckCardUpdateRequest
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

func (h *DeckCardHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.DeckCard{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckCard") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckCardHandler) Increment(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckCard") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	amount := func() int {
		v, ok := body["amount"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Increment(amount)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckCardHandler) Decrement(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckCard") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	amount := func() int {
		v, ok := body["amount"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Decrement(amount)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateDeckCard(req *model.DeckCardCreateRequest) []string {
	var errs []string
	if !((req.Quantity >= 1 && req.Quantity <= 4)) {
		errs = append(errs, "A deck can contain between 1 and 4 copies of a card")
	}
	if !((!( req.IsCommander ) || (req.Quantity == 1))) {
		errs = append(errs, "Commander card must appear exactly once in the deck")
	}
	return errs
}

func toCreateRequestDeckCard(m *model.DeckCard) model.DeckCardCreateRequest {
	return model.DeckCardCreateRequest{
		Quantity: m.Quantity,
		IsCommander: m.IsCommander,
		DeckID: m.DeckID,
		CardID: m.CardID,
	}
}
