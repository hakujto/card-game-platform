package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardSetHandler struct { db *gorm.DB }

func NewCardSetHandler(db *gorm.DB) *CardSetHandler {
	return &CardSetHandler{db: db}
}

func (h *CardSetHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/card_sets")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/card-sets/{id}/standard-legal", h.IsLegalInStandard)
	g.GET("/:id/api/card-sets/{id}/legal", h.IsLegalInFormat)
	g.GET("/:id/api/card-sets/{id}/rarity-count", h.CardCountByRarity)
	g.POST("/:id/api/card-sets/{id}/rotate", h.RotateOut)
}

func (h *CardSetHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.CardSet
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardSetResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardSetHandler) Create(c *gin.Context) {
	var req model.CardSetCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCardSet(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.CardSet{}
	row.Name = req.Name
	row.Code = req.Code
	row.ReleaseDate = req.ReleaseDate
	row.RotationDate = req.RotationDate
	row.SetType = req.SetType
	row.TotalCards = req.TotalCards
	row.IsRotated = req.IsRotated
	row.Description = req.Description
	row.LogoUrl = req.LogoUrl
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardSetHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardSetHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	var req model.CardSetUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCardSet(&row)
	if msgs := validateCardSet(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardSetHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardSetHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.CardSet{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CardSetHandler) IsLegalInStandard(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsLegalInStandard()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CardSetHandler) IsLegalInFormat(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	format := func() string {
		v, ok := body["format"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.IsLegalInFormat(format)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CardSetHandler) CardCountByRarity(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	rarity := func() string {
		v, ok := body["rarity"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.CardCountByRarity(rarity)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *CardSetHandler) RotateOut(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.CardSet
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "CardSet"); return }
		handler.DbError(c, err); return
	}
	err := row.RotateOut()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateCardSet(req *model.CardSetCreateRequest) []string {
	var errs []string
	if !(req.TotalCards > 0) {
		errs = append(errs, "Card set must have at least one card")
	}
	if !((!( req.RotationDate != nil ) || (*req.RotationDate > req.ReleaseDate))) {
		errs = append(errs, "Rotation date must be after release date")
	}
	if !((!( req.IsRotated ) || (req.RotationDate != nil))) {
		errs = append(errs, "Rotated set must have a rotation date")
	}
	return errs
}

func toCreateRequestCardSet(m *model.CardSet) model.CardSetCreateRequest {
	return model.CardSetCreateRequest{
		Name: m.Name,
		Code: m.Code,
		ReleaseDate: m.ReleaseDate,
		RotationDate: m.RotationDate,
		SetType: m.SetType,
		TotalCards: m.TotalCards,
		IsRotated: m.IsRotated,
		Description: m.Description,
		LogoUrl: m.LogoUrl,
	}
}
