package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type CardHandler struct { db *gorm.DB }

func NewCardHandler(db *gorm.DB) *CardHandler {
	return &CardHandler{db: db}
}

func (h *CardHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/cards")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/ban", h.Ban)
	g.POST("/:id/unban", h.Unban)
	g.POST("/:id/restrict", h.Restrict)
	g.POST("/:id/unrestrict", h.Unrestrict)
	g.GET("/:id/value", h.CalculateValue)
}

func (h *CardHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Card
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.CardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *CardHandler) Create(c *gin.Context) {
	var req model.CardCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateCard(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Card{}
	row.Name = req.Name
	row.CardType = req.CardType
	row.Rarity = req.Rarity
	row.ManaCost = req.ManaCost
	row.ManaColors = req.ManaColors
	row.Attack = req.Attack
	row.Defense = req.Defense
	row.Loyalty = req.Loyalty
	row.Description = req.Description
	row.FlavorText = req.FlavorText
	row.ImageUrl = req.ImageUrl
	row.ArtistName = req.ArtistName
	row.LegalFormats = req.LegalFormats
	row.IsBanned = req.IsBanned
	row.IsRestricted = req.IsRestricted
	row.PowerLevel = req.PowerLevel
	row.SetID = req.SetID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *CardHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	var req model.CardUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestCard(&row)
	if msgs := validateCard(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *CardHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *CardHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Card{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *CardHandler) Ban(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	err := row.Ban()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CardHandler) Unban(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	err := row.Unban()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CardHandler) Restrict(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	err := row.Restrict()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CardHandler) Unrestrict(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	err := row.Unrestrict()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *CardHandler) CalculateValue(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Card
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Card"); return }
		handler.DbError(c, err); return
	}
	result, err := row.CalculateValue()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateCard(req *model.CardCreateRequest) []string {
	var errs []string
	if !((!( req.CardType == model.CardCardTypeType_Creature ) || (req.Attack != nil && req.Defense != nil))) {
		errs = append(errs, "Creature card must have attack and defense")
	}
	if !((!( req.CardType == model.CardCardTypeType_Planeswalker ) || (req.Loyalty != nil))) {
		errs = append(errs, "Planeswalker card must have loyalty")
	}
	if !((req.ManaCost >= 0 && req.ManaCost <= 20)) {
		errs = append(errs, "mana_cost must be between 0 and 20")
	}
	if !((req.PowerLevel >= 1 && req.PowerLevel <= 10)) {
		errs = append(errs, "power_level must be between 1 and 10")
	}
	if !(!((req.IsBanned && req.IsRestricted))) {
		errs = append(errs, "Card cannot be both banned and restricted at the same time")
	}
	return errs
}

func toCreateRequestCard(m *model.Card) model.CardCreateRequest {
	return model.CardCreateRequest{
		Name: m.Name,
		CardType: m.CardType,
		Rarity: m.Rarity,
		ManaCost: m.ManaCost,
		ManaColors: m.ManaColors,
		Attack: m.Attack,
		Defense: m.Defense,
		Loyalty: m.Loyalty,
		Description: m.Description,
		FlavorText: m.FlavorText,
		ImageUrl: m.ImageUrl,
		ArtistName: m.ArtistName,
		LegalFormats: m.LegalFormats,
		IsBanned: m.IsBanned,
		IsRestricted: m.IsRestricted,
		PowerLevel: m.PowerLevel,
		SetID: m.SetID,
	}
}
