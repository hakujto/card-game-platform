package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckHandler struct { db *gorm.DB }

func NewDeckHandler(db *gorm.DB) *DeckHandler {
	return &DeckHandler{db: db}
}

func (h *DeckHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/decks")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Get("/:id/validate", h.ValidateSize)
	g.Post("/:id/cards", h.AddCard)
	g.Delete("/:id/cards/{card_id}", h.RemoveCard)
	g.Get("/:id/win-rate", h.WinRate)
	g.Post("/:id/clone", h.Clone)
	g.Post("/:id/publish", h.Publish)
	g.Post("/:id/unpublish", h.Unpublish)
	g.Post("/:id/certify", h.CertifyTournamentLegal)
}

func (h *DeckHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Deck
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("description LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DeckResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DeckHandler) Create(c *fiber.Ctx) error {
	var req model.DeckCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateDeck(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Deck{}
	row.Name = req.Name
	row.Description = req.Description
	row.Format = req.Format
	row.IsPublic = req.IsPublic
	row.IsTournamentLegal = req.IsTournamentLegal
	row.Archetype = req.Archetype
	row.Wins = req.Wins
	row.Losses = req.Losses
	row.Draws = req.Draws
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DeckHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DeckHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	var req model.DeckUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestDeck(&row)
	if msgs := validateDeck(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DeckHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *DeckHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.Deck{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckHandler) ValidateSize(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	result, err := row.ValidateSize()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *DeckHandler) AddCard(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	cardId := func() int {
		v, ok := body["card_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.AddCard(cardId, quantity)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckHandler) RemoveCard(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	cardId := func() int {
		v, ok := body["card_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.RemoveCard(cardId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckHandler) WinRate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	result, err := row.WinRate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *DeckHandler) Clone(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	result, err := row.Clone()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *DeckHandler) Publish(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	err := row.Publish()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckHandler) Unpublish(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	err := row.Unpublish()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DeckHandler) CertifyTournamentLegal(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Deck") }
		return handler.DbError(c, err)
	}
	result, err := row.CertifyTournamentLegal()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *DeckHandler) hookRecalculateTournamentLegal(row *model.Deck) {
	// TODO: implement recalculate_tournament_legal
}

// ── Validation rules ─────────────────────────────────────────────
func validateDeck(req *model.DeckCreateRequest) []string {
	var errs []string
	if !(req.Wins >= 0) {
		errs = append(errs, "Deck wins count must not be negative")
	}
	if !(req.Losses >= 0) {
		errs = append(errs, "Deck losses count must not be negative")
	}
	if !(req.Draws >= 0) {
		errs = append(errs, "Deck draws count must not be negative")
	}
	if !((!( req.IsTournamentLegal ) || (req.IsPublic))) {
		errs = append(errs, "Tournament-legal deck must be made public")
	}
	return errs
}

func toCreateRequestDeck(m *model.Deck) model.DeckCreateRequest {
	return model.DeckCreateRequest{
		Name: m.Name,
		Description: m.Description,
		Format: m.Format,
		IsPublic: m.IsPublic,
		IsTournamentLegal: m.IsTournamentLegal,
		Archetype: m.Archetype,
		Wins: m.Wins,
		Losses: m.Losses,
		Draws: m.Draws,
		PlayerID: m.PlayerID,
	}
}
