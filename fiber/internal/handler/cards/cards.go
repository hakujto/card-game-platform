package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardHandler struct { db *gorm.DB }

func NewCardHandler(db *gorm.DB) *CardHandler {
	return &CardHandler{db: db}
}

func (h *CardHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/cards")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/ban", h.Ban)
	g.Post("/:id/unban", h.Unban)
	g.Post("/:id/restrict", h.Restrict)
	g.Post("/:id/unrestrict", h.Unrestrict)
	g.Get("/:id/value", h.CalculateValue)
	g.Post("/:id/rarity-bonus", h.ApplyRarityBonus)
	g.Get("/:id/legal", h.IsLegalInFormat)
}

func (h *CardHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Card
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("artist_name LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CardHandler) Create(c *fiber.Ctx) error {
	var req model.CardCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateCard(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Card{}
	row.PublicId = req.PublicId
	row.Name = req.Name
	row.CardType = req.CardType
	row.Rarity = req.Rarity
	row.ManaCost = req.ManaCost
	row.ManaColors = req.ManaColors
	row.Attack = req.Attack
	row.Defense = req.Defense
	row.Loyalty = req.Loyalty
	row.Description = req.Description
	row.FlavorText = req.FlavorText
	row.ImageUrl = req.ImageUrl
	row.ArtistName = req.ArtistName
	row.LegalFormats = req.LegalFormats
	row.IsBanned = req.IsBanned
	row.IsRestricted = req.IsRestricted
	row.PowerLevel = req.PowerLevel
	row.Metadata = req.Metadata
	row.TotalCopiesInCirculation = req.TotalCopiesInCirculation
	row.SetID = req.SetID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CardHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	var req model.CardUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCard(&row)
	if msgs := validateCard(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *CardHandler) Ban(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesBan := []string{"admin", "moderator"}
	roleOkBan := false
	for _, r := range allowedRolesBan { if r == userRole { roleOkBan = true; break } }
	if !roleOkBan { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for ban"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	err := row.Ban()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardHandler) Unban(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesUnban := []string{"admin", "moderator"}
	roleOkUnban := false
	for _, r := range allowedRolesUnban { if r == userRole { roleOkUnban = true; break } }
	if !roleOkUnban { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for unban"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	err := row.Unban()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardHandler) Restrict(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesRestrict := []string{"admin", "moderator"}
	roleOkRestrict := false
	for _, r := range allowedRolesRestrict { if r == userRole { roleOkRestrict = true; break } }
	if !roleOkRestrict { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for restrict"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	err := row.Restrict()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardHandler) Unrestrict(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesUnrestrict := []string{"admin", "moderator"}
	roleOkUnrestrict := false
	for _, r := range allowedRolesUnrestrict { if r == userRole { roleOkUnrestrict = true; break } }
	if !roleOkUnrestrict { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for unrestrict"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	err := row.Unrestrict()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardHandler) Replace(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesReplace := []string{"admin"}
	roleOkReplace := false
	for _, r := range allowedRolesReplace { if r == userRole { roleOkReplace = true; break } }
	if !roleOkReplace { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for replace"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	data := func() string {
		v, ok := body["data"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.Replace(data)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardHandler) CalculateValue(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	result, err := row.CalculateValue()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardHandler) ApplyRarityBonus(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	multiplier := func() int {
		v, ok := body["multiplier"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.ApplyRarityBonus(multiplier)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardHandler) IsLegalInFormat(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Card") }
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

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *CardHandler) hookValidateLegality(row *model.Card) {
	// TODO: implement validate_legality
}

func (h *CardHandler) hookValidateNotInUse(row *model.Card) {
	// TODO: implement validate_not_in_use
}

// ── Validation rules ─────────────────────────────────────────────
func validateCard(req *model.CardCreateRequest) []string {
	var errs []string
	if (req.CardType == model.CardCardTypeType_Creature) && req.Attack == nil {
		errs = append(errs, "attack is required")
	}
	if (req.CardType == model.CardCardTypeType_Creature) && req.Defense == nil {
		errs = append(errs, "defense is required")
	}
	if (req.CardType == model.CardCardTypeType_Planeswalker) && req.Loyalty == nil {
		errs = append(errs, "loyalty is required")
	}
	if !((!( req.CardType == model.CardCardTypeType_Creature ) || (req.Attack != nil && req.Defense != nil))) {
		errs = append(errs, "Creature card must have attack and defense")
	}
	if !((!( req.CardType == model.CardCardTypeType_Planeswalker ) || (req.Loyalty != nil))) {
		errs = append(errs, "Planeswalker card must have loyalty")
	}
	if !((!( req.CardType == model.CardCardTypeType_Land ) || (req.ManaCost == 0))) {
		errs = append(errs, "Land card must have zero mana cost")
	}
	if !((!( req.CardType != model.CardCardTypeType_Planeswalker ) || (req.Loyalty == nil))) {
		errs = append(errs, "Only Planeswalker cards can have loyalty")
	}
	if !((req.ManaCost >= 0 && req.ManaCost <= 20)) {
		errs = append(errs, "mana_cost must be between 0 and 20")
	}
	if !((req.PowerLevel >= 1 && req.PowerLevel <= 10)) {
		errs = append(errs, "power_level must be between 1 and 10")
	}
	if !(!((req.IsBanned && req.IsRestricted))) {
		errs = append(errs, "Card cannot be both banned and restricted at the same time")
	}
	if !((!( req.IsBanned ) || (len(req.LegalFormats) == 0))) {
		errs = append(errs, "Banned card must not appear in any legal formats")
	}
	return errs
}

func toCreateRequestCard(m *model.Card) model.CardCreateRequest {
	return model.CardCreateRequest{
		PublicId: m.PublicId,
		Name: m.Name,
		CardType: m.CardType,
		Rarity: m.Rarity,
		ManaCost: m.ManaCost,
		ManaColors: m.ManaColors,
		Attack: m.Attack,
		Defense: m.Defense,
		Loyalty: m.Loyalty,
		Description: m.Description,
		FlavorText: m.FlavorText,
		ImageUrl: m.ImageUrl,
		ArtistName: m.ArtistName,
		LegalFormats: m.LegalFormats,
		IsBanned: m.IsBanned,
		IsRestricted: m.IsRestricted,
		PowerLevel: m.PowerLevel,
		Metadata: m.Metadata,
		TotalCopiesInCirculation: m.TotalCopiesInCirculation,
		SetID: m.SetID,
	}
}
