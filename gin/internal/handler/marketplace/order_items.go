package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type OrderItemHandler struct { db *gorm.DB }

func NewOrderItemHandler(db *gorm.DB) *OrderItemHandler {
	return &OrderItemHandler{db: db}
}

func (h *OrderItemHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/order_items")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/order-items/{id}/total", h.LineTotal)
}

func (h *OrderItemHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.OrderItem
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.OrderItemResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *OrderItemHandler) Create(c *gin.Context) {
	var req model.OrderItemCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateOrderItem(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.OrderItem{}
	row.Quantity = req.Quantity
	row.PriceAtPurchase = req.PriceAtPurchase
	row.Foil = req.Foil
	row.OrderID = req.OrderID
	row.ProductID = req.ProductID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *OrderItemHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.OrderItem
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "OrderItem"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *OrderItemHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.OrderItem
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "OrderItem"); return }
		handler.DbError(c, err); return
	}
	var req model.OrderItemUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestOrderItem(&row)
	if msgs := validateOrderItem(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *OrderItemHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *OrderItemHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.OrderItem{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "OrderItem"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *OrderItemHandler) LineTotal(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.OrderItem
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "OrderItem"); return }
		handler.DbError(c, err); return
	}
	result, err := row.LineTotal()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateOrderItem(req *model.OrderItemCreateRequest) []string {
	var errs []string
	if !(req.Quantity > 0) {
		errs = append(errs, "Order item quantity must be greater than zero")
	}
	if !(float64(req.PriceAtPurchase) >= 0) {
		errs = append(errs, "Price at purchase must not be negative")
	}
	return errs
}

func toCreateRequestOrderItem(m *model.OrderItem) model.OrderItemCreateRequest {
	return model.OrderItemCreateRequest{
		Quantity: m.Quantity,
		PriceAtPurchase: m.PriceAtPurchase,
		Foil: m.Foil,
		OrderID: m.OrderID,
		ProductID: m.ProductID,
	}
}
