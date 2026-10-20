package handler_cards

import (
	"regexp"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardSetHandler struct { db *gorm.DB }

func NewCardSetHandler(db *gorm.DB) *CardSetHandler {
	return &CardSetHandler{db: db}
}

func (h *CardSetHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/card_sets")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Get("/:id/standard-legal", h.IsLegalInStandard)
	g.Get("/:id/legal", h.IsLegalInFormat)
	g.Get("/:id/rarity-count", h.CardCountByRarity)
	g.Post("/:id/rotate", h.RotateOut)
}

func (h *CardSetHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CardSet
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("code LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CardSetResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CardSetHandler) Create(c *fiber.Ctx) error {
	var req model.CardSetCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateCardSet(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.CardSet{}
	row.Name = req.Name
	row.Code = req.Code
	row.ReleaseDate = req.ReleaseDate
	row.RotationDate = req.RotationDate
	row.SetType = req.SetType
	row.TotalCards = req.TotalCards
	row.IsRotated = req.IsRotated
	row.Description = req.Description
	row.LogoUrl = req.LogoUrl
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CardSetHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardSetHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	var req model.CardSetUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCardSet(&row)
	if msgs := validateCardSet(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardSetHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *CardSetHandler) IsLegalInStandard(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	result, err := row.IsLegalInStandard()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardSetHandler) IsLegalInFormat(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	format := func() string {
		v, ok := body["format"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.IsLegalInFormat(format)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardSetHandler) CardCountByRarity(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	rarity := func() string {
		v, ok := body["rarity"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.CardCountByRarity(rarity)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardSetHandler) RotateOut(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardSet") }
		return handler.DbError(c, err)
	}
	err := row.RotateOut()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateCardSet(req *model.CardSetCreateRequest) []string {
	var errs []string
	if matched, _ := regexp.MatchString(`[A-Z]{2,6}`, req.Code); !matched {
		errs = append(errs, "code has invalid format")
	}
	if !(req.TotalCards > 0) {
		errs = append(errs, "Card set must have at least one card")
	}
	if !((!( req.RotationDate != nil ) || (*req.RotationDate > req.ReleaseDate))) {
		errs = append(errs, "Rotation date must be after release date")
	}
	if !((!( req.IsRotated ) || (req.RotationDate != nil))) {
		errs = append(errs, "Rotated set must have a rotation date")
	}
	return errs
}

func toCreateRequestCardSet(m *model.CardSet) model.CardSetCreateRequest {
	return model.CardSetCreateRequest{
		Name: m.Name,
		Code: m.Code,
		ReleaseDate: m.ReleaseDate,
		RotationDate: m.RotationDate,
		SetType: m.SetType,
		TotalCards: m.TotalCards,
		IsRotated: m.IsRotated,
		Description: m.Description,
		LogoUrl: m.LogoUrl,
	}
}
