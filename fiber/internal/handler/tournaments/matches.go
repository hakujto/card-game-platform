package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type MatchHandler struct { db *gorm.DB }

func NewMatchHandler(db *gorm.DB) *MatchHandler {
	return &MatchHandler{db: db}
}

func (h *MatchHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/matches")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/record", h.RecordResult)
	g.Post("/:id/finalize", h.FinalizeResult)
	g.Get("/:id/winner", h.DetermineWinner)
	g.Post("/:id/concede", h.Concede)
	g.Post("/:id/draw", h.Draw)
	g.Patch("/:id/transitions/pending-to-active", h.TransitionPendingToActive)
	g.Patch("/:id/transitions/active-to-completed", h.TransitionActiveToCompleted)
	g.Patch("/:id/transitions/active-to-draw", h.TransitionActiveToDraw)
	g.Patch("/:id/transitions/pending-to-bye", h.TransitionPendingToBYE)
	g.Patch("/:id/transitions/completed-to-active", h.TransitionCompletedToActive)
	g.Patch("/:id/transitions/draw-to-active", h.TransitionDrawToActive)
	g.Patch("/:id/transitions/bye-to-active", h.TransitionBYEToActive)
}

func (h *MatchHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Match
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.MatchResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *MatchHandler) Create(c *fiber.Ctx) error {
	var req model.MatchCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateMatch(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Match{}
	row.TableNumber = req.TableNumber
	row.Status = req.Status
	row.Player1Wins = req.Player1Wins
	row.Player2Wins = req.Player2Wins
	row.StartedAt = req.StartedAt
	row.EndedAt = req.EndedAt
	row.ResultNotes = req.ResultNotes
	row.RoundID = req.RoundID
	row.Player1ID = req.Player1ID
	row.Player2ID = req.Player2ID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *MatchHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *MatchHandler) RecordResult(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	p1Wins := func() int {
		v, ok := body["p1_wins"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	p2Wins := func() int {
		v, ok := body["p2_wins"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.RecordResult(p1Wins, p2Wins)
	if err != nil { return handler.DbError(c, err) }
	_, _ = row.DetermineWinner() // @after
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *MatchHandler) FinalizeResult(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	err := row.FinalizeResult()
	if err != nil { return handler.DbError(c, err) }
	_, _ = row.DetermineWinner() // @after
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *MatchHandler) DetermineWinner(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	result, err := row.DetermineWinner()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *MatchHandler) Concede(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	if !(row.Status == model.MatchStatusType_Active) {
		return handler.UnprocessableError(c, "Guard condition not met for concede")
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Concede(playerId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *MatchHandler) Draw(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	err := row.Draw()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *MatchHandler) TransitionPendingToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPendingToActive := []string{"Judge", "HeadJudge", "Admin"}
	roleOkTransitionPendingToActive := false
	for _, r := range allowedRolesTransitionPendingToActive { if r == userRole { roleOkTransitionPendingToActive = true; break } }
	if !roleOkTransitionPendingToActive { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Pending -> Active"}) }
	if err := row.AssertTransition("Active"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.MatchStatusType_Active
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *MatchHandler) TransitionActiveToCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionActiveToCompleted := []string{"Judge", "HeadJudge", "Admin"}
	roleOkTransitionActiveToCompleted := false
	for _, r := range allowedRolesTransitionActiveToCompleted { if r == userRole { roleOkTransitionActiveToCompleted = true; break } }
	if !roleOkTransitionActiveToCompleted { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Active -> Completed"}) }
	if err := row.AssertTransition("Completed"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.MatchStatusType_Completed
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.FinalizeResult() // @after
	return c.JSON(row.ToResponse())
}

func (h *MatchHandler) TransitionActiveToDraw(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionActiveToDraw := []string{"Judge", "HeadJudge", "Admin"}
	roleOkTransitionActiveToDraw := false
	for _, r := range allowedRolesTransitionActiveToDraw { if r == userRole { roleOkTransitionActiveToDraw = true; break } }
	if !roleOkTransitionActiveToDraw { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Active -> Draw"}) }
	if err := row.AssertTransition("Draw"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.MatchStatusType_Draw
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Draw() // @after
	return c.JSON(row.ToResponse())
}

func (h *MatchHandler) TransitionPendingToBYE(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPendingToBYE := []string{"Judge", "HeadJudge", "Admin"}
	roleOkTransitionPendingToBYE := false
	for _, r := range allowedRolesTransitionPendingToBYE { if r == userRole { roleOkTransitionPendingToBYE = true; break } }
	if !roleOkTransitionPendingToBYE { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Pending -> BYE"}) }
	if err := row.AssertTransition("BYE"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.MatchStatusType_BYE
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *MatchHandler) TransitionCompletedToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Completed -> Active is not allowed")
}

func (h *MatchHandler) TransitionDrawToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Draw -> Active is not allowed")
}

func (h *MatchHandler) TransitionBYEToActive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Match") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition BYE -> Active is not allowed")
}

// ── Validation rules ─────────────────────────────────────────────
func validateMatch(req *model.MatchCreateRequest) []string {
	var errs []string
	if !((req.Player1Wins >= 0 && req.Player2Wins >= 0)) {
		errs = append(errs, "Win counts must not be negative")
	}
	if !(((req.Player1Wins >= 0 && req.Player1Wins <= 2) && (req.Player2Wins >= 0 && req.Player2Wins <= 2))) {
		errs = append(errs, "Win counts cannot exceed 2 in a best-of-3 match")
	}
	if !((!( req.Status == model.MatchStatusType_BYE ) || (req.Player2ID == nil))) {
		errs = append(errs, "BYE match must not have a second player")
	}
	if !((!( req.EndedAt != nil ) || ((req.StartedAt != nil && *req.EndedAt > *req.StartedAt)))) {
		errs = append(errs, "Match end time must be after start time")
	}
	if !((!( req.Status == model.MatchStatusType_Completed ) || (req.StartedAt != nil))) {
		errs = append(errs, "Completed match must have a start time")
	}
	return errs
}

func toCreateRequestMatch(m *model.Match) model.MatchCreateRequest {
	return model.MatchCreateRequest{
		TableNumber: m.TableNumber,
		Status: m.Status,
		Player1Wins: m.Player1Wins,
		Player2Wins: m.Player2Wins,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		ResultNotes: m.ResultNotes,
		RoundID: m.RoundID,
		Player1ID: m.Player1ID,
		Player2ID: m.Player2ID,
	}
}
