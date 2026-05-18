package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type CraftingIngredientHandler struct { db *gorm.DB }

func NewCraftingIngredientHandler(db *gorm.DB) *CraftingIngredientHandler {
	return &CraftingIngredientHandler{db: db}
}

func (h *CraftingIngredientHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/crafting_ingredients")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *CraftingIngredientHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CraftingIngredient
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CraftingIngredientResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CraftingIngredientHandler) Create(c *gin.Context) {
	var req model.CraftingIngredientCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.CraftingIngredient{}
	row.Quantity = req.Quantity
	row.RecipeID = req.RecipeID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CraftingIngredientHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingIngredient
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingIngredient"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CraftingIngredientHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CraftingIngredient
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingIngredient"); return }
		handler.DbError(c, err); return
	}
	var req model.CraftingIngredientUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CraftingIngredientHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CraftingIngredientHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CraftingIngredient{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CraftingIngredient"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
