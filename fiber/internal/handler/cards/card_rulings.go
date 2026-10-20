package handler_cards

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardRulingHandler struct { db *gorm.DB }

func NewCardRulingHandler(db *gorm.DB) *CardRulingHandler {
	return &CardRulingHandler{db: db}
}

func (h *CardRulingHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/card_rulings")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
	g.Get("/:id/current", h.IsCurrent)
	g.Get("/:id/supersedes", h.SupersedesPrevious)
}

func (h *CardRulingHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CardRuling
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CardRulingResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CardRulingHandler) Create(c *fiber.Ctx) error {
	var req model.CardRulingCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.CardRuling{}
	row.RulingText = req.RulingText
	row.PublishedAt = req.PublishedAt
	row.Source = req.Source
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CardRulingHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardRuling") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CardRulingHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.CardRuling{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardRuling") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CardRulingHandler) IsCurrent(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardRuling") }
		return handler.DbError(c, err)
	}
	result, err := row.IsCurrent()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CardRulingHandler) SupersedesPrevious(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CardRuling
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CardRuling") }
		return handler.DbError(c, err)
	}
	result, err := row.SupersedesPrevious()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}
