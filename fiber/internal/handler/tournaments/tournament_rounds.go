package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentRoundHandler struct { db *gorm.DB }

func NewTournamentRoundHandler(db *gorm.DB) *TournamentRoundHandler {
	return &TournamentRoundHandler{db: db}
}

func (h *TournamentRoundHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/tournament_rounds")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/api/rounds/{id}/start", h.Start)
	g.Post("/:id/api/rounds/{id}/complete", h.Complete)
	g.Post("/:id/api/rounds/{id}/pairings", h.GeneratePairings)
	g.Get("/:id/api/rounds/{id}/time-expired", h.IsTimeExpired)
}

func (h *TournamentRoundHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentRound
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TournamentRoundResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TournamentRoundHandler) Create(c *fiber.Ctx) error {
	var req model.TournamentRoundCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTournamentRound(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TournamentRound{}
	row.RoundNumber = req.RoundNumber
	row.Status = req.Status
	row.StartedAt = req.StartedAt
	row.EndedAt = req.EndedAt
	row.TimeLimitMinutes = req.TimeLimitMinutes
	row.TournamentID = req.TournamentID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TournamentRoundHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRound") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentRoundHandler) Start(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRound") }
		return handler.DbError(c, err)
	}
	err := row.Start()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentRoundHandler) Complete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRound") }
		return handler.DbError(c, err)
	}
	err := row.Complete()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentRoundHandler) GeneratePairings(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRound") }
		return handler.DbError(c, err)
	}
	err := row.GeneratePairings()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentRoundHandler) IsTimeExpired(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRound") }
		return handler.DbError(c, err)
	}
	result, err := row.IsTimeExpired()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateTournamentRound(req *model.TournamentRoundCreateRequest) []string {
	var errs []string
	if !((!( req.EndedAt != nil ) || ((req.StartedAt != nil && *req.EndedAt > *req.StartedAt)))) {
		errs = append(errs, "Round end time must be after start time")
	}
	if !((!( req.Status == model.TournamentRoundStatusType_Completed ) || (req.StartedAt != nil))) {
		errs = append(errs, "Completed round must have a start time")
	}
	if !(req.RoundNumber > 0) {
		errs = append(errs, "Round number must be greater than zero")
	}
	if !(req.TimeLimitMinutes > 0) {
		errs = append(errs, "Round time limit must be greater than zero")
	}
	return errs
}

func toCreateRequestTournamentRound(m *model.TournamentRound) model.TournamentRoundCreateRequest {
	return model.TournamentRoundCreateRequest{
		RoundNumber: m.RoundNumber,
		Status: m.Status,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		TimeLimitMinutes: m.TimeLimitMinutes,
		TournamentID: m.TournamentID,
	}
}
