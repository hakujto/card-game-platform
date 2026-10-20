package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftParticipantHandler struct { db *gorm.DB }

func NewDraftParticipantHandler(db *gorm.DB) *DraftParticipantHandler {
	return &DraftParticipantHandler{db: db}
}

func (h *DraftParticipantHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/draft_participants")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Post("/:id/pick", h.PickCard)
	g.Get("/:id/card-count", h.DraftedCardCount)
}

func (h *DraftParticipantHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftParticipant
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DraftParticipantResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DraftParticipantHandler) Create(c *fiber.Ctx) error {
	var req model.DraftParticipantCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateDraftParticipant(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.DraftParticipant{}
	row.SeatNumber = req.SeatNumber
	row.JoinedAt = req.JoinedAt
	row.SessionID = req.SessionID
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DraftParticipantHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftParticipant") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DraftParticipantHandler) PickCard(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftParticipant") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	cardId := func() int {
		v, ok := body["card_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	packNumber := func() int {
		v, ok := body["pack_number"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.PickCard(cardId, packNumber)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *DraftParticipantHandler) DraftedCardCount(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DraftParticipant
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DraftParticipant") }
		return handler.DbError(c, err)
	}
	result, err := row.DraftedCardCount()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateDraftParticipant(req *model.DraftParticipantCreateRequest) []string {
	var errs []string
	if !(req.SeatNumber > 0) {
		errs = append(errs, "Seat number must be greater than zero")
	}
	return errs
}

func toCreateRequestDraftParticipant(m *model.DraftParticipant) model.DraftParticipantCreateRequest {
	return model.DraftParticipantCreateRequest{
		SeatNumber: m.SeatNumber,
		JoinedAt: m.JoinedAt,
		SessionID: m.SessionID,
		PlayerID: m.PlayerID,
	}
}
