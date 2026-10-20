package handler_tournaments

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type AwardedPrizeHandler struct { db *gorm.DB }

func NewAwardedPrizeHandler(db *gorm.DB) *AwardedPrizeHandler {
	return &AwardedPrizeHandler{db: db}
}

func (h *AwardedPrizeHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/awarded_prizes")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Post("/:id/claim", h.Claim)
}

func (h *AwardedPrizeHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.AwardedPrize
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.AwardedPrizeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *AwardedPrizeHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "AwardedPrize") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *AwardedPrizeHandler) Claim(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "AwardedPrize") }
		return handler.DbError(c, err)
	}
	err := row.Claim()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *AwardedPrizeHandler) SetClaimed(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var body struct{ Value bool `json:"value"` }
	if err := c.BodyParser(&body); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "AwardedPrize") }
		return handler.DbError(c, err)
	}
	row.Claimed = body.Value
	if row.Claimed == true {
		_ = row.Claim() // @on(claimed = true)
	}
	h.db.Save(&row)
	return c.JSON(row.ToResponse())
}

// ── Validation rules ─────────────────────────────────────────────
func validateAwardedPrize(req *model.AwardedPrizeCreateRequest) []string {
	var errs []string
	if (req.Claimed == true) && req.ClaimedAt == nil {
		errs = append(errs, "claimed_at is required")
	}
	if !((!( req.Claimed ) || (req.ClaimedAt != nil))) {
		errs = append(errs, "Claimed prize must have a claimed_at timestamp")
	}
	if !(req.FinalPlacement > 0) {
		errs = append(errs, "Final placement must be greater than zero")
	}
	return errs
}

func toCreateRequestAwardedPrize(m *model.AwardedPrize) model.AwardedPrizeCreateRequest {
	return model.AwardedPrizeCreateRequest{
		FinalPlacement: m.FinalPlacement,
		AwardedAt: m.AwardedAt,
		Claimed: m.Claimed,
		ClaimedAt: m.ClaimedAt,
		PrizeID: m.PrizeID,
		PlayerID: m.PlayerID,
	}
}
