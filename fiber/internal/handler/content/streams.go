package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type StreamHandler struct { db *gorm.DB }

func NewStreamHandler(db *gorm.DB) *StreamHandler {
	return &StreamHandler{db: db}
}

func (h *StreamHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/streams")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/live", h.GoLive)
	g.Post("/:id/end", h.End)
	g.Patch("/:id/viewers", h.UpdateViewerPeak)
	g.Get("/:id/duration", h.DurationMinutes)
	g.Patch("/:id/transitions/scheduled-to-live", h.TransitionScheduledToLive)
	g.Patch("/:id/transitions/live-to-ended", h.TransitionLiveToEnded)
	g.Patch("/:id/transitions/ended-to-live", h.TransitionEndedToLive)
}

func (h *StreamHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Stream
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("title LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.StreamResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *StreamHandler) Create(c *fiber.Ctx) error {
	var req model.StreamCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateStream(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Stream{}
	row.Title = req.Title
	row.StreamUrl = req.StreamUrl
	row.Status = req.Status
	row.Platform = req.Platform
	row.Language = req.Language
	row.IsOfficial = req.IsOfficial
	row.ViewerCountPeak = req.ViewerCountPeak
	row.ScheduledStart = req.ScheduledStart
	row.ActualStart = req.ActualStart
	row.EndedAt = req.EndedAt
	row.VodUrl = req.VodUrl
	row.TournamentID = req.TournamentID
	row.StreamerID = req.StreamerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *StreamHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *StreamHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	var req model.StreamUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestStream(&row)
	if msgs := validateStream(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *StreamHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *StreamHandler) GoLive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	err := row.GoLive()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *StreamHandler) End(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	err := row.End()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *StreamHandler) UpdateViewerPeak(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	count := func() int {
		v, ok := body["count"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.UpdateViewerPeak(count)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *StreamHandler) DurationMinutes(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	result, err := row.DurationMinutes()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *StreamHandler) TransitionScheduledToLive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionScheduledToLive := []string{"Streamer", "Admin"}
	roleOkTransitionScheduledToLive := false
	for _, r := range allowedRolesTransitionScheduledToLive { if r == userRole { roleOkTransitionScheduledToLive = true; break } }
	if !roleOkTransitionScheduledToLive { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Scheduled -> Live"}) }
	if err := row.AssertTransition("Live"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.StreamUrl == "" {
		return handler.UnprocessableError(c, "stream_url is required for this transition")
	}
	row.Status = model.StreamStatusType_Live
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.GoLive() // @after
	return c.JSON(row.ToResponse())
}

func (h *StreamHandler) TransitionLiveToEnded(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionLiveToEnded := []string{"Streamer", "Admin"}
	roleOkTransitionLiveToEnded := false
	for _, r := range allowedRolesTransitionLiveToEnded { if r == userRole { roleOkTransitionLiveToEnded = true; break } }
	if !roleOkTransitionLiveToEnded { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Live -> Ended"}) }
	if err := row.AssertTransition("Ended"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.StreamStatusType_Ended
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.End() // @after
	return c.JSON(row.ToResponse())
}

func (h *StreamHandler) TransitionEndedToLive(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Stream") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Ended -> Live is not allowed")
}

// ── Validation rules ─────────────────────────────────────────────
func validateStream(req *model.StreamCreateRequest) []string {
	var errs []string
	if !((!( req.ActualStart != nil ) || (req.Status == model.StreamStatusType_Live))) {
		errs = append(errs, "actual_start_requires_live_or_ended")
	}
	if !((!( req.EndedAt != nil ) || (req.Status == model.StreamStatusType_Ended))) {
		errs = append(errs, "ended_at can only be set when stream status is Ended")
	}
	if !(req.ViewerCountPeak >= 0) {
		errs = append(errs, "Peak viewer count must not be negative")
	}
	return errs
}

func toCreateRequestStream(m *model.Stream) model.StreamCreateRequest {
	return model.StreamCreateRequest{
		Title: m.Title,
		StreamUrl: m.StreamUrl,
		Status: m.Status,
		Platform: m.Platform,
		Language: m.Language,
		IsOfficial: m.IsOfficial,
		ViewerCountPeak: m.ViewerCountPeak,
		ScheduledStart: m.ScheduledStart,
		ActualStart: m.ActualStart,
		EndedAt: m.EndedAt,
		VodUrl: m.VodUrl,
		TournamentID: m.TournamentID,
		StreamerID: m.StreamerID,
	}
}
