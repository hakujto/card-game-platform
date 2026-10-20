package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type AchievementHandler struct { db *gorm.DB }

func NewAchievementHandler(db *gorm.DB) *AchievementHandler {
	return &AchievementHandler{db: db}
}

func (h *AchievementHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/achievements")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Get("/:id/point-value", h.PointValue)
	g.Post("/:id/reveal", h.Reveal)
}

func (h *AchievementHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Achievement
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("description LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.AchievementResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *AchievementHandler) Create(c *fiber.Ctx) error {
	var req model.AchievementCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateAchievement(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Achievement{}
	row.Name = req.Name
	row.Description = req.Description
	row.IconUrl = req.IconUrl
	row.Points = req.Points
	row.Rarity = req.Rarity
	row.IsHidden = req.IsHidden
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *AchievementHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Achievement") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *AchievementHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Achievement") }
		return handler.DbError(c, err)
	}
	var req model.AchievementUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestAchievement(&row)
	if msgs := validateAchievement(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *AchievementHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *AchievementHandler) PointValue(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Achievement") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	multiplier := func() int {
		v, ok := body["multiplier"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.PointValue(multiplier)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *AchievementHandler) Reveal(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Achievement") }
		return handler.DbError(c, err)
	}
	err := row.Reveal()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateAchievement(req *model.AchievementCreateRequest) []string {
	var errs []string
	if !(req.Points > 0) {
		errs = append(errs, "Achievement must award at least one point")
	}
	return errs
}

func toCreateRequestAchievement(m *model.Achievement) model.AchievementCreateRequest {
	return model.AchievementCreateRequest{
		Name: m.Name,
		Description: m.Description,
		IconUrl: m.IconUrl,
		Points: m.Points,
		Rarity: m.Rarity,
		IsHidden: m.IsHidden,
	}
}
