package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerAchievementHandler struct { db *gorm.DB }

func NewPlayerAchievementHandler(db *gorm.DB) *PlayerAchievementHandler {
	return &PlayerAchievementHandler{db: db}
}

func (h *PlayerAchievementHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/player_achievements")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Patch("/:id/progress", h.IncrementProgress)
	g.Post("/:id/complete", h.Complete)
}

func (h *PlayerAchievementHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerAchievement
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.PlayerAchievementResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *PlayerAchievementHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerAchievement") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *PlayerAchievementHandler) IncrementProgress(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerAchievement") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	amount := func() int {
		v, ok := body["amount"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.IncrementProgress(amount)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerAchievementHandler) Complete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerAchievement") }
		return handler.DbError(c, err)
	}
	err := row.Complete()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerAchievementHandler) SetIsCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var body struct{ Value bool `json:"value"` }
	if err := c.BodyParser(&body); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerAchievement") }
		return handler.DbError(c, err)
	}
	row.IsCompleted = body.Value
	if row.IsCompleted == true {
		_ = row.Complete() // @on(is_completed = true)
	}
	h.db.Save(&row)
	return c.JSON(row.ToResponse())
}

// ── Validation rules ─────────────────────────────────────────────
func validatePlayerAchievement(req *model.PlayerAchievementCreateRequest) []string {
	var errs []string
	if !((!( req.IsCompleted ) || (req.Progress > 0))) {
		errs = append(errs, "Completed achievement must have progress greater than zero")
	}
	if !(req.Progress >= 0) {
		errs = append(errs, "Achievement progress must not be negative")
	}
	return errs
}

func toCreateRequestPlayerAchievement(m *model.PlayerAchievement) model.PlayerAchievementCreateRequest {
	return model.PlayerAchievementCreateRequest{
		EarnedAt: m.EarnedAt,
		Progress: m.Progress,
		IsCompleted: m.IsCompleted,
		PlayerID: m.PlayerID,
		AchievementID: m.AchievementID,
	}
}
