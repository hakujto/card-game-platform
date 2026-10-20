package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftPickHandler struct { db *gorm.DB }

func NewDraftPickHandler(db *gorm.DB) *DraftPickHandler {
	return &DraftPickHandler{db: db}
}

func (h *DraftPickHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/draft_picks")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Get("/:id/first-pick", h.IsFirstPick)
}

func (h *DraftPickHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftPick
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DraftPickResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DraftPickHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftPick") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DraftPickHandler) IsFirstPick(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftPick") }
		return handler.DbError(c, err)
	}
	result, err := row.IsFirstPick()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateDraftPick(req *model.DraftPickCreateRequest) []string {
	var errs []string
	if !(req.PickNumber > 0) {
		errs = append(errs, "Pick number must be greater than zero")
	}
	if !((req.PackNumber >= 1 && req.PackNumber <= 3)) {
		errs = append(errs, "Pack number must be between 1 and 3")
	}
	return errs
}

func toCreateRequestDraftPick(m *model.DraftPick) model.DraftPickCreateRequest {
	return model.DraftPickCreateRequest{
		PickNumber: m.PickNumber,
		PackNumber: m.PackNumber,
		PickedAt: m.PickedAt,
		ParticipantID: m.ParticipantID,
		CardID: m.CardID,
	}
}
