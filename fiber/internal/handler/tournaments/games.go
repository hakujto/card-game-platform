package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type GameHandler struct { db *gorm.DB }

func NewGameHandler(db *gorm.DB) *GameHandler {
	return &GameHandler{db: db}
}

func (h *GameHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/games")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/winner", h.RecordWinner)
	g.Get("/:id/duration", h.DurationMinutes)
}

func (h *GameHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Game
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.GameResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *GameHandler) Create(c *fiber.Ctx) error {
	var req model.GameCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateGame(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Game{}
	row.GameNumber = req.GameNumber
	row.WinnerSide = req.WinnerSide
	row.ComplexityScore = req.ComplexityScore
	row.TurnsPlayed = req.TurnsPlayed
	row.DurationSeconds = req.DurationSeconds
	row.EndedBy = req.EndedBy
	row.ReplayUrl = req.ReplayUrl
	row.MatchID = req.MatchID
	row.WinnerID = req.WinnerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *GameHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Game") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *GameHandler) RecordWinner(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Game") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	winnerSide := func() string {
		v, ok := body["winner_side"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.RecordWinner(winnerSide)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *GameHandler) DurationMinutes(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Game") }
		return handler.DbError(c, err)
	}
	result, err := row.DurationMinutes()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateGame(req *model.GameCreateRequest) []string {
	var errs []string
	if !((req.GameNumber >= 1 && req.GameNumber <= 3)) {
		errs = append(errs, "Game number must be between 1 and 3 (best-of-3)")
	}
	if !((!( req.TurnsPlayed != nil ) || (*req.TurnsPlayed > 0))) {
		errs = append(errs, "Turns played must be greater than zero")
	}
	if !((!( req.DurationSeconds != nil ) || (*req.DurationSeconds > 0))) {
		errs = append(errs, "Game duration must be greater than zero")
	}
	if !((!( (req.WinnerSide != nil && *req.WinnerSide == model.GameWinnerSideType_Draw) ) || (req.WinnerID == nil))) {
		errs = append(errs, "A draw cannot have a winner")
	}
	if !((!( (req.WinnerSide != nil && (req.WinnerSide == nil || *req.WinnerSide != model.GameWinnerSideType_Draw)) ) || (req.WinnerID != nil))) {
		errs = append(errs, "A decisive game must have a winner player set")
	}
	return errs
}

func toCreateRequestGame(m *model.Game) model.GameCreateRequest {
	return model.GameCreateRequest{
		GameNumber: m.GameNumber,
		WinnerSide: m.WinnerSide,
		ComplexityScore: m.ComplexityScore,
		TurnsPlayed: m.TurnsPlayed,
		DurationSeconds: m.DurationSeconds,
		EndedBy: m.EndedBy,
		ReplayUrl: m.ReplayUrl,
		MatchID: m.MatchID,
		WinnerID: m.WinnerID,
	}
}
