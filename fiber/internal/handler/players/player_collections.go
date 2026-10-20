package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerCollectionHandler struct { db *gorm.DB }

func NewPlayerCollectionHandler(db *gorm.DB) *PlayerCollectionHandler {
	return &PlayerCollectionHandler{db: db}
}

func (h *PlayerCollectionHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/player_collections")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Post("/:id/api/collection/{id}/add", h.Add)
	g.Post("/:id/api/collection/{id}/remove", h.Remove)
	g.Get("/:id/api/collection/{id}/value", h.EstimatedValue)
}

func (h *PlayerCollectionHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerCollection
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.PlayerCollectionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *PlayerCollectionHandler) Create(c *fiber.Ctx) error {
	var req model.PlayerCollectionCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validatePlayerCollection(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.PlayerCollection{}
	row.Quantity = req.Quantity
	row.Foil = req.Foil
	row.Condition = req.Condition
	row.AcquiredAt = req.AcquiredAt
	row.AcquiredVia = req.AcquiredVia
	row.PlayerID = req.PlayerID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *PlayerCollectionHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.PlayerID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	return c.JSON(row.ToResponse())
}

func (h *PlayerCollectionHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.PlayerID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	var req model.PlayerCollectionUpdateRequest
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

func (h *PlayerCollectionHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.PlayerID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	if err := h.db.Delete(&row).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerCollectionHandler) Add(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Add(quantity)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerCollectionHandler) Remove(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Remove(quantity)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerCollectionHandler) EstimatedValue(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerCollection") }
		return handler.DbError(c, err)
	}
	result, err := row.EstimatedValue()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validatePlayerCollection(req *model.PlayerCollectionCreateRequest) []string {
	var errs []string
	if !(req.Quantity > 0) {
		errs = append(errs, "Collection quantity must be greater than zero")
	}
	return errs
}

func toCreateRequestPlayerCollection(m *model.PlayerCollection) model.PlayerCollectionCreateRequest {
	return model.PlayerCollectionCreateRequest{
		Quantity: m.Quantity,
		Foil: m.Foil,
		Condition: m.Condition,
		AcquiredAt: m.AcquiredAt,
		AcquiredVia: m.AcquiredVia,
		PlayerID: m.PlayerID,
		CardID: m.CardID,
	}
}
