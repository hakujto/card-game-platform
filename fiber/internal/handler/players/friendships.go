package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type FriendshipHandler struct { db *gorm.DB }

func NewFriendshipHandler(db *gorm.DB) *FriendshipHandler {
	return &FriendshipHandler{db: db}
}

func (h *FriendshipHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/friendships")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
	g.Post("/:id/accept", h.Accept)
	g.Post("/:id/decline", h.Decline)
	g.Post("/:id/block", h.Block)
}

func (h *FriendshipHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Friendship
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.FriendshipResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *FriendshipHandler) Create(c *fiber.Ctx) error {
	var req model.FriendshipCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.Friendship{}
	row.Status = req.Status
	row.RequesterID = req.RequesterID
	row.ReceiverID = req.ReceiverID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *FriendshipHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.RequesterID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	return c.JSON(row.ToResponse())
}

func (h *FriendshipHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	uid, _ := c.Locals("user_id").(uint)
	if row.RequesterID != uid {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "You do not own this resource."})
	}
	if err := h.db.Delete(&row).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *FriendshipHandler) Accept(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	err := row.Accept()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *FriendshipHandler) Decline(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	err := row.Decline()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *FriendshipHandler) Block(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Friendship") }
		return handler.DbError(c, err)
	}
	err := row.Block()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}
