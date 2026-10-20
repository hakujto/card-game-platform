package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardAbilityHandler struct { db *gorm.DB }

func NewCardAbilityHandler(db *gorm.DB) *CardAbilityHandler {
	return &CardAbilityHandler{db: db}
}

func (h *CardAbilityHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/card_abilities")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Get("/:id/usable", h.IsUsableAt)
	g.Get("/:id/describe", h.Describe)
}

func (h *CardAbilityHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CardAbility
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("keyword LIKE ?", "%"+q+"%")
		db = db.Or("ability_text LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CardAbilityResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CardAbilityHandler) Create(c *fiber.Ctx) error {
	var req model.CardAbilityCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateCardAbility(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.CardAbility{}
	row.AbilityType = req.AbilityType
	row.Keyword = req.Keyword
	row.AbilityText = req.AbilityText
	row.Timing = req.Timing
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CardAbilityHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardAbility") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardAbilityHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardAbility") }
		return handler.DbError(c, err)
	}
	var req model.CardAbilityUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCardAbility(&row)
	if msgs := validateCardAbility(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardAbilityHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *CardAbilityHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.CardAbility{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardAbility") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardAbilityHandler) IsUsableAt(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardAbility") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	timing := func() string {
		v, ok := body["timing"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.IsUsableAt(timing)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardAbilityHandler) Describe(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardAbility") }
		return handler.DbError(c, err)
	}
	result, err := row.Describe()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateCardAbility(req *model.CardAbilityCreateRequest) []string {
	var errs []string
	if !((!( req.AbilityType == model.CardAbilityAbilityTypeType_Keyword ) || (req.Keyword != nil))) {
		errs = append(errs, "Keyword ability must have a keyword name")
	}
	return errs
}

func toCreateRequestCardAbility(m *model.CardAbility) model.CardAbilityCreateRequest {
	return model.CardAbilityCreateRequest{
		AbilityType: m.AbilityType,
		Keyword: m.Keyword,
		AbilityText: m.AbilityText,
		Timing: m.Timing,
		CardID: m.CardID,
	}
}
