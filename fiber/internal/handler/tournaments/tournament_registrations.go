package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentRegistrationHandler struct { db *gorm.DB }

func NewTournamentRegistrationHandler(db *gorm.DB) *TournamentRegistrationHandler {
	return &TournamentRegistrationHandler{db: db}
}

func (h *TournamentRegistrationHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/tournament_registrations")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/api/registrations/{id}/withdraw", h.Withdraw)
	g.Post("/:id/api/registrations/{id}/disqualify", h.Disqualify)
	g.Post("/:id/api/registrations/{id}/promote", h.PromoteFromWaitlist)
}

func (h *TournamentRegistrationHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentRegistration
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TournamentRegistrationResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TournamentRegistrationHandler) Create(c *fiber.Ctx) error {
	var req model.TournamentRegistrationCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTournamentRegistration(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TournamentRegistration{}
	row.Status = req.Status
	row.Seed = req.Seed
	row.FinalStanding = req.FinalStanding
	row.PointsEarned = req.PointsEarned
	row.RegisteredAt = req.RegisteredAt
	row.TournamentID = req.TournamentID
	row.PlayerID = req.PlayerID
	row.DeckID = req.DeckID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TournamentRegistrationHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRegistration") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.PlayerID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentRegistrationHandler) Withdraw(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRegistration") }
		return handler.DbError(c, err)
	}
	err := row.Withdraw()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentRegistrationHandler) Disqualify(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRegistration") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	reason := func() string {
		v, ok := body["reason"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Disqualify(reason)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentRegistrationHandler) PromoteFromWaitlist(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentRegistration") }
		return handler.DbError(c, err)
	}
	err := row.PromoteFromWaitlist()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateTournamentRegistration(req *model.TournamentRegistrationCreateRequest) []string {
	var errs []string
	if !(req.PointsEarned >= 0) {
		errs = append(errs, "Points earned must not be negative")
	}
	if !((!( req.FinalStanding != nil ) || (*req.FinalStanding > 0))) {
		errs = append(errs, "Final standing must be greater than zero")
	}
	if !((!( req.Seed != nil ) || (*req.Seed > 0))) {
		errs = append(errs, "Seed must be greater than zero")
	}
	return errs
}

func toCreateRequestTournamentRegistration(m *model.TournamentRegistration) model.TournamentRegistrationCreateRequest {
	return model.TournamentRegistrationCreateRequest{
		Status: m.Status,
		Seed: m.Seed,
		FinalStanding: m.FinalStanding,
		PointsEarned: m.PointsEarned,
		RegisteredAt: m.RegisteredAt,
		TournamentID: m.TournamentID,
		PlayerID: m.PlayerID,
		DeckID: m.DeckID,
	}
}
