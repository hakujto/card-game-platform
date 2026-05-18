package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardAbilityHandler struct { db *gorm.DB }

func NewCardAbilityHandler(db *gorm.DB) *CardAbilityHandler {
	return &CardAbilityHandler{db: db}
}

func (h *CardAbilityHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/card_abilities")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/card-abilities/{id}/usable", h.IsUsableAt)
	g.GET("/:id/api/card-abilities/{id}/describe", h.Describe)
}

func (h *CardAbilityHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CardAbility
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardAbilityResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardAbilityHandler) Create(c *gin.Context) {
	var req model.CardAbilityCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCardAbility(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.CardAbility{}
	row.AbilityType = req.AbilityType
	row.Keyword = req.Keyword
	row.AbilityText = req.AbilityText
	row.Timing = req.Timing
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardAbilityHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardAbility"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardAbilityHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardAbility"); return }
		handler.DbError(c, err); return
	}
	var req model.CardAbilityUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCardAbility(&row)
	if msgs := validateCardAbility(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardAbilityHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardAbilityHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CardAbility{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardAbility"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CardAbilityHandler) IsUsableAt(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardAbility"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	timing := func() string {
		v, ok := body["timing"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.IsUsableAt(timing)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CardAbilityHandler) Describe(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardAbility
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardAbility"); return }
		handler.DbError(c, err); return
	}
	result, err := row.Describe()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateCardAbility(req *model.CardAbilityCreateRequest) []string {
	var errs []string
	if !((!( req.AbilityType == model.CardAbilityAbilityTypeType_Keyword ) || (req.Keyword != nil))) {
		errs = append(errs, "Keyword ability must have a keyword name")
	}
	return errs
}

func toCreateRequestCardAbility(m *model.CardAbility) model.CardAbilityCreateRequest {
	return model.CardAbilityCreateRequest{
		AbilityType: m.AbilityType,
		Keyword: m.Keyword,
		AbilityText: m.AbilityText,
		Timing: m.Timing,
		CardID: m.CardID,
	}
}
