package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type SeasonHandler struct { db *gorm.DB }

func NewSeasonHandler(db *gorm.DB) *SeasonHandler {
	return &SeasonHandler{db: db}
}

func (h *SeasonHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/seasons")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/activate", h.Activate)
	g.Post("/:id/deactivate", h.Deactivate)
	g.Post("/:id/finalize", h.FinalizeRewards)
	g.Get("/:id/ongoing", h.IsOngoing)
}

func (h *SeasonHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Season
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.SeasonResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *SeasonHandler) Create(c *fiber.Ctx) error {
	var req model.SeasonCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateSeason(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.Season{}
	row.Name = req.Name
	row.StartDate = req.StartDate
	row.EndDate = req.EndDate
	row.Format = req.Format
	row.IsActive = req.IsActive
	row.RewardDescription = req.RewardDescription
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *SeasonHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *SeasonHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	var req model.SeasonUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestSeason(&row)
	if msgs := validateSeason(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *SeasonHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *SeasonHandler) Activate(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesActivate := []string{"admin"}
	roleOkActivate := false
	for _, r := range allowedRolesActivate { if r == userRole { roleOkActivate = true; break } }
	if !roleOkActivate { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for activate"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	err := row.Activate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *SeasonHandler) Deactivate(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesDeactivate := []string{"admin"}
	roleOkDeactivate := false
	for _, r := range allowedRolesDeactivate { if r == userRole { roleOkDeactivate = true; break } }
	if !roleOkDeactivate { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for deactivate"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	err := row.Deactivate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *SeasonHandler) FinalizeRewards(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesFinalizeRewards := []string{"admin"}
	roleOkFinalizeRewards := false
	for _, r := range allowedRolesFinalizeRewards { if r == userRole { roleOkFinalizeRewards = true; break } }
	if !roleOkFinalizeRewards { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for finalize_rewards"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	err := row.FinalizeRewards()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *SeasonHandler) IsOngoing(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Season") }
		return handler.DbError(c, err)
	}
	result, err := row.IsOngoing()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateSeason(req *model.SeasonCreateRequest) []string {
	var errs []string
	if !(req.EndDate > req.StartDate) {
		errs = append(errs, "Season end date must be after start date")
	}
	return errs
}

func toCreateRequestSeason(m *model.Season) model.SeasonCreateRequest {
	return model.SeasonCreateRequest{
		Name: m.Name,
		StartDate: m.StartDate,
		EndDate: m.EndDate,
		Format: m.Format,
		IsActive: m.IsActive,
		RewardDescription: m.RewardDescription,
	}
}
