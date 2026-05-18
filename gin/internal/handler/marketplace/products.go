package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type ProductHandler struct { db *gorm.DB }

func NewProductHandler(db *gorm.DB) *ProductHandler {
	return &ProductHandler{db: db}
}

func (h *ProductHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/products")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/activate", h.Activate)
	g.POST("/:id/deactivate", h.Deactivate)
	g.PATCH("/:id/discount", h.ApplyDiscount)
	g.POST("/:id/restock", h.Restock)
}

func (h *ProductHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Product
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.ProductResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *ProductHandler) Create(c *gin.Context) {
	var req model.ProductCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.Product{}
	row.Name = req.Name
	row.ProductType = req.ProductType
	row.Price = req.Price
	row.Stock = req.Stock
	row.Active = req.Active
	row.DiscountPercent = req.DiscountPercent
	row.Description = req.Description
	row.ImageUrl = req.ImageUrl
	row.Featured = req.Featured
	row.CardID = req.CardID
	row.CardSetID = req.CardSetID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *ProductHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ProductHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	var req model.ProductUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ProductHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *ProductHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Product{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *ProductHandler) Activate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	err := row.Activate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ProductHandler) Deactivate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	err := row.Deactivate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ProductHandler) ApplyDiscount(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	percent := func() int {
		v, ok := body["percent"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.ApplyDiscount(percent)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *ProductHandler) Restock(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Product
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Product"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Restock(quantity)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
