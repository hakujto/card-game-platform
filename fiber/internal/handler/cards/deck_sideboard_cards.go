package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckSideboardCardHandler struct { db *gorm.DB }

func NewDeckSideboardCardHandler(db *gorm.DB) *DeckSideboardCardHandler {
	return &DeckSideboardCardHandler{db: db}
}

func (h *DeckSideboardCardHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/deck_sideboard_cards")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Patch("/:id/api/sideboard-cards/{id}/increment", h.Increment)
	g.Patch("/:id/api/sideboard-cards/{id}/decrement", h.Decrement)
}

func (h *DeckSideboardCardHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckSideboardCard
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DeckSideboardCardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DeckSideboardCardHandler) Create(c *fiber.Ctx) error {
	var req model.DeckSideboardCardCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateDeckSideboardCard(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.DeckSideboardCard{}
	row.Quantity = req.Quantity
	row.DeckID = req.DeckID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DeckSideboardCardHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckSideboardCard") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DeckSideboardCardHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckSideboardCard") }
		return handler.DbError(c, err)
	}
	var req model.DeckSideboardCardUpdateRequest
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

func (h *DeckSideboardCardHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.DeckSideboardCard{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckSideboardCard") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckSideboardCardHandler) Increment(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckSideboardCard") }
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

func (h *DeckSideboardCardHandler) Decrement(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckSideboardCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckSideboardCard") }
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
func validateDeckSideboardCard(req *model.DeckSideboardCardCreateRequest) []string {
	var errs []string
	if !((req.Quantity >= 1 && req.Quantity <= 4)) {
		errs = append(errs, "Sideboard card quantity must be between 1 and 4 copies")
	}
	return errs
}

func toCreateRequestDeckSideboardCard(m *model.DeckSideboardCard) model.DeckSideboardCardCreateRequest {
	return model.DeckSideboardCardCreateRequest{
		Quantity: m.Quantity,
		DeckID: m.DeckID,
		CardID: m.CardID,
	}
}
