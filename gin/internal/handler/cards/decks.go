package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckHandler struct { db *gorm.DB }

func NewDeckHandler(db *gorm.DB) *DeckHandler {
	return &DeckHandler{db: db}
}

func (h *DeckHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/decks")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/validate", h.ValidateSize)
	g.POST("/:id/clone", h.Clone)
	g.POST("/:id/publish", h.Publish)
	g.POST("/:id/unpublish", h.Unpublish)
	g.POST("/:id/certify", h.CertifyTournamentLegal)
}

func (h *DeckHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Deck
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DeckResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DeckHandler) Create(c *gin.Context) {
	var req model.DeckCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.Deck{}
	row.Name = req.Name
	row.Description = req.Description
	row.Format = req.Format
	row.IsPublic = req.IsPublic
	row.IsTournamentLegal = req.IsTournamentLegal
	row.Archetype = req.Archetype
	row.Wins = req.Wins
	row.Losses = req.Losses
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DeckHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	var req model.DeckUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DeckHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Deck{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *DeckHandler) ValidateSize(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	result, err := row.ValidateSize()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *DeckHandler) Clone(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	result, err := row.Clone()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *DeckHandler) Publish(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	err := row.Publish()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DeckHandler) Unpublish(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	err := row.Unpublish()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *DeckHandler) CertifyTournamentLegal(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Deck
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Deck"); return }
		handler.DbError(c, err); return
	}
	result, err := row.CertifyTournamentLegal()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}
