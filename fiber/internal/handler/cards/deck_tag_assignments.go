package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckTagAssignmentHandler struct { db *gorm.DB }

func NewDeckTagAssignmentHandler(db *gorm.DB) *DeckTagAssignmentHandler {
	return &DeckTagAssignmentHandler{db: db}
}

func (h *DeckTagAssignmentHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/deck_tag_assignments")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
}

func (h *DeckTagAssignmentHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckTagAssignment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.DeckTagAssignmentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *DeckTagAssignmentHandler) Create(c *fiber.Ctx) error {
	var req model.DeckTagAssignmentCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.DeckTagAssignment{}
	row.DeckID = req.DeckID
	row.TagID = req.TagID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *DeckTagAssignmentHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.DeckTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckTagAssignment") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *DeckTagAssignmentHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.DeckTagAssignment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "DeckTagAssignment") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}
