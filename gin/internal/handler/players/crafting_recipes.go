package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type CraftingRecipeHandler struct { db *gorm.DB }

func NewCraftingRecipeHandler(db *gorm.DB) *CraftingRecipeHandler {
	return &CraftingRecipeHandler{db: db}
}

func (h *CraftingRecipeHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/crafting_recipes")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/crafting-recipes/{id}/can-craft", h.CanCraft)
	g.POST("/:id/api/crafting-recipes/{id}/craft", h.ExecuteCraft)
	g.POST("/:id/api/crafting-recipes/{id}/disable", h.Disable)
	g.POST("/:id/api/crafting-recipes/{id}/enable", h.Enable)
}

func (h *CraftingRecipeHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CraftingRecipe
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CraftingRecipeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CraftingRecipeHandler) Create(c *gin.Context) {
	var req model.CraftingRecipeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCraftingRecipe(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.CraftingRecipe{}
	row.DustCost = req.DustCost
	row.IsAvailable = req.IsAvailable
	row.ResultCardID = req.ResultCardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CraftingRecipeHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CraftingRecipeHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	var req model.CraftingRecipeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCraftingRecipe(&row)
	if msgs := validateCraftingRecipe(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CraftingRecipeHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CraftingRecipeHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CraftingRecipe{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CraftingRecipeHandler) CanCraft(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.CanCraft(playerId)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CraftingRecipeHandler) ExecuteCraft(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.ExecuteCraft(playerId)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CraftingRecipeHandler) Disable(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	err := row.Disable()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CraftingRecipeHandler) Enable(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingRecipe
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingRecipe"); return }
		handler.DbError(c, err); return
	}
	err := row.Enable()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

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
