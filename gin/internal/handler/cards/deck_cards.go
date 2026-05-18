package handler_cards

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/cards"
	"cards_project/internal/handler"
)

type DeckCardHandler struct { db *gorm.DB }

func NewDeckCardHandler(db *gorm.DB) *DeckCardHandler {
	return &DeckCardHandler{db: db}
}

func (h *DeckCardHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/deck_cards")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *DeckCardHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DeckCard
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DeckCardResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DeckCardHandler) Create(c *gin.Context) {
	var req model.DeckCardCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateDeckCard(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.DeckCard{}
	row.Quantity = req.Quantity
	row.IsCommander = req.IsCommander
	row.DeckID = req.DeckID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *DeckCardHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckCard"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckCardHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DeckCard
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckCard"); return }
		handler.DbError(c, err); return
	}
	var req model.DeckCardUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestDeckCard(&row)
	if msgs := validateDeckCard(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DeckCardHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *DeckCardHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.DeckCard{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DeckCard"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func validateDeckCard(req *model.DeckCardCreateRequest) []string {
	var errs []string
	if !((req.Quantity >= 1 && req.Quantity <= 4)) {
		errs = append(errs, "A deck can contain between 1 and 4 copies of a card")
	}
	return errs
}

func toCreateRequestDeckCard(m *model.DeckCard) model.DeckCardCreateRequest {
	return model.DeckCardCreateRequest{
		Quantity: m.Quantity,
		IsCommander: m.IsCommander,
		DeckID: m.DeckID,
		CardID: m.CardID,
	}
}
