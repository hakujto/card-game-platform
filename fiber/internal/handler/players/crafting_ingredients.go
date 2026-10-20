package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type CraftingIngredientHandler struct { db *gorm.DB }

func NewCraftingIngredientHandler(db *gorm.DB) *CraftingIngredientHandler {
	return &CraftingIngredientHandler{db: db}
}

func (h *CraftingIngredientHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/crafting_ingredients")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
}

func (h *CraftingIngredientHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CraftingIngredient
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CraftingIngredientResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CraftingIngredientHandler) Create(c *fiber.Ctx) error {
	var req model.CraftingIngredientCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.CraftingIngredient{}
	row.Quantity = req.Quantity
	row.RecipeID = req.RecipeID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CraftingIngredientHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingIngredient
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingIngredient") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CraftingIngredientHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.CraftingIngredient{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingIngredient") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}
