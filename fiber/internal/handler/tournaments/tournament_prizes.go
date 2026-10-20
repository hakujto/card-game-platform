package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentPrizeHandler struct { db *gorm.DB }

func NewTournamentPrizeHandler(db *gorm.DB) *TournamentPrizeHandler {
	return &TournamentPrizeHandler{db: db}
}

func (h *TournamentPrizeHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/tournament_prizes")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Get("/:id/api/prizes/{id}/applies", h.AppliesToPlacement)
	g.Post("/:id/api/prizes/{id}/award", h.AwardToPlayer)
}

func (h *TournamentPrizeHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentPrize
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.TournamentPrizeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *TournamentPrizeHandler) Create(c *fiber.Ctx) error {
	var req model.TournamentPrizeCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateTournamentPrize(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.TournamentPrize{}
	row.PlacementFrom = req.PlacementFrom
	row.PlacementTo = req.PlacementTo
	row.PrizeType = req.PrizeType
	row.Amount = req.Amount
	row.Description = req.Description
	row.PacksCount = req.PacksCount
	row.SeasonPoints = req.SeasonPoints
	row.TournamentID = req.TournamentID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *TournamentPrizeHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentPrize") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentPrizeHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentPrize") }
		return handler.DbError(c, err)
	}
	var req model.TournamentPrizeUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournamentPrize(&row)
	if msgs := validateTournamentPrize(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *TournamentPrizeHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *TournamentPrizeHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.TournamentPrize{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentPrize") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *TournamentPrizeHandler) AppliesToPlacement(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentPrize") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	placement := func() int {
		v, ok := body["placement"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.AppliesToPlacement(placement)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *TournamentPrizeHandler) AwardToPlayer(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "TournamentPrize") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.AwardToPlayer(playerId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateTournamentPrize(req *model.TournamentPrizeCreateRequest) []string {
	var errs []string
	if !(req.PlacementTo >= req.PlacementFrom) {
		errs = append(errs, "placement_to must be greater than or equal to placement_from")
	}
	if !(req.PlacementFrom > 0) {
		errs = append(errs, "placement_from must be greater than zero")
	}
	if !(float64(req.Amount) >= 0) {
		errs = append(errs, "Prize amount must not be negative")
	}
	return errs
}

func toCreateRequestTournamentPrize(m *model.TournamentPrize) model.TournamentPrizeCreateRequest {
	return model.TournamentPrizeCreateRequest{
		PlacementFrom: m.PlacementFrom,
		PlacementTo: m.PlacementTo,
		PrizeType: m.PrizeType,
		Amount: m.Amount,
		Description: m.Description,
		PacksCount: m.PacksCount,
		SeasonPoints: m.SeasonPoints,
		TournamentID: m.TournamentID,
	}
}
