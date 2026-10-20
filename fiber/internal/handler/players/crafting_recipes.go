package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type CraftingRecipeHandler struct { db *gorm.DB }

func NewCraftingRecipeHandler(db *gorm.DB) *CraftingRecipeHandler {
	return &CraftingRecipeHandler{db: db}
}

func (h *CraftingRecipeHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/crafting_recipes")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Get("/:id/can-craft", h.CanCraft)
	g.Post("/:id/craft", h.ExecuteCraft)
	g.Post("/:id/disable", h.Disable)
	g.Post("/:id/enable", h.Enable)
}

func (h *CraftingRecipeHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.CraftingRecipe
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.CraftingRecipeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *CraftingRecipeHandler) Create(c *fiber.Ctx) error {
	var req model.CraftingRecipeCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateCraftingRecipe(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	row := model.CraftingRecipe{}
	row.DustCost = req.DustCost
	row.IsAvailable = req.IsAvailable
	row.ResultCardID = req.ResultCardID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *CraftingRecipeHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CraftingRecipeHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	var req model.CraftingRecipeUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCraftingRecipe(&row)
	if msgs := validateCraftingRecipe(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *CraftingRecipeHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *CraftingRecipeHandler) CanCraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.CanCraft(playerId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *CraftingRecipeHandler) ExecuteCraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.ExecuteCraft(playerId)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CraftingRecipeHandler) Disable(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	err := row.Disable()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *CraftingRecipeHandler) Enable(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "CraftingRecipe") }
		return handler.DbError(c, err)
	}
	err := row.Enable()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validateCraftingRecipe(req *model.CraftingRecipeCreateRequest) []string {
	var errs []string
	if !(req.DustCost > 0) {
		errs = append(errs, "Crafting recipe must have a dust cost greater than zero")
	}
	return errs
}

func toCreateRequestCraftingRecipe(m *model.CraftingRecipe) model.CraftingRecipeCreateRequest {
	return model.CraftingRecipeCreateRequest{
		DustCost: m.DustCost,
		IsAvailable: m.IsAvailable,
		ResultCardID: m.ResultCardID,
	}
}
