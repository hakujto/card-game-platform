package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentHandler struct { db *gorm.DB }

func NewTournamentHandler(db *gorm.DB) *TournamentHandler {
	return &TournamentHandler{db: db}
}

func (h *TournamentHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/tournaments")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/start", h.Start)
	g.Post("/:id/cancel", h.Cancel)
	g.Post("/:id/complete", h.Complete)
	g.Post("/:id/rounds", h.GenerateRound)
	g.Get("/:id/prizes", h.CalculatePrizeDistribution)
	g.Post("/:id/register", h.RegisterPlayer)
	g.Get("/:id/full", h.IsFull)
	g.Patch("/:id/transitions/draft-to-registration", h.TransitionDraftToRegistration)
	g.Patch("/:id/transitions/registration-to-ongoing", h.TransitionRegistrationToOngoing)
	g.Patch("/:id/transitions/registration-to-cancelled", h.TransitionRegistrationToCancelled)
	g.Patch("/:id/transitions/ongoing-to-completed", h.TransitionOngoingToCompleted)
	g.Patch("/:id/transitions/ongoing-to-cancelled", h.TransitionOngoingToCancelled)
	g.Patch("/:id/transitions/completed-to-draft", h.TransitionCompletedToDraft)
	g.Patch("/:id/transitions/cancelled-to-draft", h.TransitionCancelledToDraft)
}

func (h *TournamentHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Tournament
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
		db = db.Or("description LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TournamentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TournamentHandler) Create(c *fiber.Ctx) error {
	var req model.TournamentCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTournament(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Tournament{}
	row.PublicId = req.PublicId
	row.Name = req.Name
	row.Description = req.Description
	row.Status = req.Status
	row.BracketData = req.BracketData
	row.Format = req.Format
	row.TournamentType = req.TournamentType
	row.MaxPlayers = req.MaxPlayers
	row.EntryFee = req.EntryFee
	row.PrizePool = req.PrizePool
	row.StartTime = req.StartTime
	row.EndTime = req.EndTime
	row.IsOnline = req.IsOnline
	row.Location = req.Location
	row.RulesText = req.RulesText
	row.SeasonID = req.SeasonID
	row.OrganizerID = req.OrganizerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TournamentHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	var req model.TournamentUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournament(&row)
	if msgs := validateTournament(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *TournamentHandler) Start(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	err := row.Start()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentHandler) Cancel(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	err := row.Cancel()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentHandler) Complete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	err := row.Complete()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentHandler) GenerateRound(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	err := row.GenerateRound()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentHandler) CalculatePrizeDistribution(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	result, err := row.CalculatePrizeDistribution()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *TournamentHandler) RegisterPlayer(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	deckId := func() int {
		v, ok := body["deck_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.RegisterPlayer(playerId, deckId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentHandler) IsFull(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	result, err := row.IsFull()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *TournamentHandler) TransitionDraftToRegistration(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionDraftToRegistration := []string{"Admin", "Organizer"}
	roleOkTransitionDraftToRegistration := false
	for _, r := range allowedRolesTransitionDraftToRegistration { if r == userRole { roleOkTransitionDraftToRegistration = true; break } }
	if !roleOkTransitionDraftToRegistration { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Draft -> Registration"}) }
	if err := row.AssertTransition("Registration"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.Name == "" {
		return handler.UnprocessableError(c, "name is required for this transition")
	}
	if row.StartTime == "" {
		return handler.UnprocessableError(c, "start_time is required for this transition")
	}
	row.Status = model.TournamentStatusType_Registration
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) TransitionRegistrationToOngoing(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionRegistrationToOngoing := []string{"Admin", "Organizer"}
	roleOkTransitionRegistrationToOngoing := false
	for _, r := range allowedRolesTransitionRegistrationToOngoing { if r == userRole { roleOkTransitionRegistrationToOngoing = true; break } }
	if !roleOkTransitionRegistrationToOngoing { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Registration -> Ongoing"}) }
	if err := row.AssertTransition("Ongoing"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TournamentStatusType_Ongoing
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Start() // @after
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) TransitionRegistrationToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionRegistrationToCancelled := []string{"Admin", "Organizer"}
	roleOkTransitionRegistrationToCancelled := false
	for _, r := range allowedRolesTransitionRegistrationToCancelled { if r == userRole { roleOkTransitionRegistrationToCancelled = true; break } }
	if !roleOkTransitionRegistrationToCancelled { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Registration -> Cancelled"}) }
	if err := row.AssertTransition("Cancelled"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TournamentStatusType_Cancelled
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Cancel() // @after
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) TransitionOngoingToCompleted(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionOngoingToCompleted := []string{"Admin", "Organizer"}
	roleOkTransitionOngoingToCompleted := false
	for _, r := range allowedRolesTransitionOngoingToCompleted { if r == userRole { roleOkTransitionOngoingToCompleted = true; break } }
	if !roleOkTransitionOngoingToCompleted { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Ongoing -> Completed"}) }
	if err := row.AssertTransition("Completed"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TournamentStatusType_Completed
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Complete() // @after
	_, _ = row.CalculatePrizeDistribution() // @after
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) TransitionOngoingToCancelled(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionOngoingToCancelled := []string{"Admin"}
	roleOkTransitionOngoingToCancelled := false
	for _, r := range allowedRolesTransitionOngoingToCancelled { if r == userRole { roleOkTransitionOngoingToCancelled = true; break } }
	if !roleOkTransitionOngoingToCancelled { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Ongoing -> Cancelled"}) }
	if err := row.AssertTransition("Cancelled"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.TournamentStatusType_Cancelled
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Cancel() // @after
	return c.JSON(row.ToResponse())
}

func (h *TournamentHandler) TransitionCompletedToDraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Completed -> Draft is not allowed")
}

func (h *TournamentHandler) TransitionCancelledToDraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Tournament") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Cancelled -> Draft is not allowed")
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *TournamentHandler) hookSyncSeasonStats(row *model.Tournament) {
	// TODO: implement sync_season_stats
}

func (h *TournamentHandler) hookPreventDeleteIfOngoing(row *model.Tournament) {
	// TODO: implement prevent_delete_if_ongoing
}

// ── Validation rules ─────────────────────────────────────────────
func validateTournament(req *model.TournamentCreateRequest) []string {
	var errs []string
	if !((req.MaxPlayers >= 2 && req.MaxPlayers <= 512)) {
		errs = append(errs, "Tournament must allow between 2 and 512 players")
	}
	if !(float64(req.EntryFee) >= 0) {
		errs = append(errs, "Entry fee must not be negative")
	}
	if !(float64(req.PrizePool) >= 0) {
		errs = append(errs, "Prize pool must not be negative")
	}
	if !((!( req.EndTime != nil ) || (*req.EndTime > req.StartTime))) {
		errs = append(errs, "End time must be after start time")
	}
	return errs
}

func toCreateRequestTournament(m *model.Tournament) model.TournamentCreateRequest {
	return model.TournamentCreateRequest{
		PublicId: m.PublicId,
		Name: m.Name,
		Description: m.Description,
		Status: m.Status,
		BracketData: m.BracketData,
		Format: m.Format,
		TournamentType: m.TournamentType,
		MaxPlayers: m.MaxPlayers,
		EntryFee: m.EntryFee,
		PrizePool: m.PrizePool,
		StartTime: m.StartTime,
		EndTime: m.EndTime,
		IsOnline: m.IsOnline,
		Location: m.Location,
		RulesText: m.RulesText,
		SeasonID: m.SeasonID,
		OrganizerID: m.OrganizerID,
	}
}
