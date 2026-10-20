package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentJudgeHandler struct { db *gorm.DB }

func NewTournamentJudgeHandler(db *gorm.DB) *TournamentJudgeHandler {
	return &TournamentJudgeHandler{db: db}
}

func (h *TournamentJudgeHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/tournament_judges")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
	g.Post("/:id/promote", h.PromoteToHead)
}

func (h *TournamentJudgeHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentJudge
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TournamentJudgeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TournamentJudgeHandler) Create(c *fiber.Ctx) error {
	var req model.TournamentJudgeCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.TournamentJudge{}
	row.Role = req.Role
	row.TournamentID = req.TournamentID
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TournamentJudgeHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentJudge") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentJudgeHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.TournamentJudge{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentJudge") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentJudgeHandler) PromoteToHead(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentJudge") }
		return handler.DbError(c, err)
	}
	err := row.PromoteToHead()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentJudgeHandler) Remove(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentJudge") }
		return handler.DbError(c, err)
	}
	err := row.Remove()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}
