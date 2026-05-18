package handler_marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/marketplace"
	"cards_project/internal/handler"
)

type CouponHandler struct { db *gorm.DB }

func NewCouponHandler(db *gorm.DB) *CouponHandler {
	return &CouponHandler{db: db}
}

func (h *CouponHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/coupons")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/valid", h.IsValid)
	g.GET("/:id/applicable", h.IsApplicableToOrder)
	g.POST("/:id/redeem", h.Redeem)
	g.POST("/:id/deactivate", h.Deactivate)
}

func (h *CouponHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Coupon
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CouponResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CouponHandler) Create(c *gin.Context) {
	var req model.CouponCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCoupon(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Coupon{}
	row.Code = req.Code
	row.DiscountType = req.DiscountType
	row.DiscountValue = req.DiscountValue
	row.MinOrderValue = req.MinOrderValue
	row.MaxUses = req.MaxUses
	row.UsesCount = req.UsesCount
	row.ValidFrom = req.ValidFrom
	row.ValidUntil = req.ValidUntil
	row.IsActive = req.IsActive
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CouponHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CouponHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	var req model.CouponUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCoupon(&row)
	if msgs := validateCoupon(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CouponHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CouponHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Coupon{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CouponHandler) IsValid(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsValid()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CouponHandler) IsApplicableToOrder(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	orderTotal := func() float64 {
		v, ok := body["order_total"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return f
	}()
	result, err := row.IsApplicableToOrder(orderTotal)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CouponHandler) Redeem(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	err := row.Redeem()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CouponHandler) Deactivate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Coupon
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Coupon"); return }
		handler.DbError(c, err); return
	}
	err := row.Deactivate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateCoupon(req *model.CouponCreateRequest) []string {
	var errs []string
	if !(req.ValidUntil > req.ValidFrom) {
		errs = append(errs, "Coupon expiry must be after its start date")
	}
	if !(float64(req.DiscountValue) > 0) {
		errs = append(errs, "Discount value must be greater than zero")
	}
	if !((!( req.DiscountType == model.CouponDiscountTypeType_Percent ) || ((float64(req.DiscountValue) >= 1 && float64(req.DiscountValue) <= 100)))) {
		errs = append(errs, "Percent discount must be between 1 and 100")
	}
	if !((!( req.MaxUses != nil ) || ((req.MaxUses != nil && req.UsesCount <= *req.MaxUses)))) {
		errs = append(errs, "Coupon uses count cannot exceed max_uses")
	}
	return errs
}

func toCreateRequestCoupon(m *model.Coupon) model.CouponCreateRequest {
	return model.CouponCreateRequest{
		Code: m.Code,
		DiscountType: m.DiscountType,
		DiscountValue: m.DiscountValue,
		MinOrderValue: m.MinOrderValue,
		MaxUses: m.MaxUses,
		UsesCount: m.UsesCount,
		ValidFrom: m.ValidFrom,
		ValidUntil: m.ValidUntil,
		IsActive: m.IsActive,
	}
}
