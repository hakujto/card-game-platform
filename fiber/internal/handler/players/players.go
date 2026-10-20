package handler_players

import (
	"regexp"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerHandler struct { db *gorm.DB }

func NewPlayerHandler(db *gorm.DB) *PlayerHandler {
	return &PlayerHandler{db: db}
}

func (h *PlayerHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/players")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/promote", h.Promote)
	g.Post("/:id/demote", h.Demote)
	g.Post("/:id/win", h.RecordWin)
	g.Post("/:id/loss", h.RecordLoss)
	g.Get("/:id/win-rate", h.WinRate)
	g.Post("/:id/verify", h.Verify)
	g.Patch("/:id/rating", h.UpdateRating)
}

func (h *PlayerHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Player
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("display_name LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.PlayerResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *PlayerHandler) Create(c *fiber.Ctx) error {
	var req model.PlayerCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validatePlayer(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Player{}
	row.PublicId = req.PublicId
	row.DisplayName = req.DisplayName
	row.Rank = req.Rank
	row.Rating = req.Rating
	row.PeakRating = req.PeakRating
	row.Bio = req.Bio
	row.CountryCode = req.CountryCode
	row.AvatarUrl = req.AvatarUrl
	row.PreferredFormat = req.PreferredFormat
	row.ContactEmail = req.ContactEmail
	row.WinRateCached = req.WinRateCached
	row.IsVerified = req.IsVerified
	row.LastActiveAt = req.LastActiveAt
	row.UserID = req.UserID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *PlayerHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *PlayerHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	var req model.PlayerUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *PlayerHandler) Promote(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	result, err := row.Promote()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *PlayerHandler) Demote(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	result, err := row.Demote()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *PlayerHandler) RecordWin(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	err := row.RecordWin()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerHandler) RecordLoss(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	err := row.RecordLoss()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerHandler) WinRate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	result, err := row.WinRate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *PlayerHandler) Verify(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesVerify := []string{"admin"}
	roleOkVerify := false
	for _, r := range allowedRolesVerify { if r == userRole { roleOkVerify = true; break } }
	if !roleOkVerify { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for verify"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	err := row.Verify()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerHandler) UpdateRating(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Player") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	delta := func() int {
		v, ok := body["delta"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.UpdateRating(delta)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *PlayerHandler) hookInitializeCollection(row *model.Player) {
	// TODO: implement initialize_collection
}

func (h *PlayerHandler) hookUpdateRank(row *model.Player) {
	// TODO: implement update_rank
}

// ── Validation rules ─────────────────────────────────────────────
func validatePlayer(req *model.PlayerCreateRequest) []string {
	var errs []string
	if req.CountryCode != nil {
		if matched, _ := regexp.MatchString(`[A-Z]{2}`, *req.CountryCode); !matched {
			errs = append(errs, "country_code has invalid format")
		}
	}
	if !((req.Rating >= 0 && req.Rating <= 9999)) {
		errs = append(errs, "Rating must be between 0 and 9999")
	}
	if !(req.PeakRating >= req.Rating) {
		errs = append(errs, "Peak rating must be greater than or equal to current rating")
	}
	if !(req.DisplayName != "") {
		errs = append(errs, "Display name must not be empty")
	}
	return errs
}

func toCreateRequestPlayer(m *model.Player) model.PlayerCreateRequest {
	return model.PlayerCreateRequest{
		PublicId: m.PublicId,
		DisplayName: m.DisplayName,
		Rank: m.Rank,
		Rating: m.Rating,
		PeakRating: m.PeakRating,
		Bio: m.Bio,
		CountryCode: m.CountryCode,
		AvatarUrl: m.AvatarUrl,
		PreferredFormat: m.PreferredFormat,
		ContactEmail: m.ContactEmail,
		WinRateCached: m.WinRateCached,
		IsVerified: m.IsVerified,
		LastActiveAt: m.LastActiveAt,
		UserID: m.UserID,
	}
}
