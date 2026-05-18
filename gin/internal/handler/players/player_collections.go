package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerCollectionHandler struct { db *gorm.DB }

func NewPlayerCollectionHandler(db *gorm.DB) *PlayerCollectionHandler {
	return &PlayerCollectionHandler{db: db}
}

func (h *PlayerCollectionHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/player_collections")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/collection/{id}/add", h.Add)
	g.POST("/:id/api/collection/{id}/remove", h.Remove)
	g.GET("/:id/api/collection/{id}/value", h.EstimatedValue)
}

func (h *PlayerCollectionHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerCollection
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.PlayerCollectionResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *PlayerCollectionHandler) Create(c *gin.Context) {
	var req model.PlayerCollectionCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validatePlayerCollection(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.PlayerCollection{}
	row.Quantity = req.Quantity
	row.Foil = req.Foil
	row.Condition = req.Condition
	row.AcquiredAt = req.AcquiredAt
	row.AcquiredVia = req.AcquiredVia
	row.PlayerID = req.PlayerID
	row.CardID = req.CardID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *PlayerCollectionHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerCollectionHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	var req model.PlayerCollectionUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestPlayerCollection(&row)
	if msgs := validatePlayerCollection(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerCollectionHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *PlayerCollectionHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.PlayerCollection{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *PlayerCollectionHandler) Add(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Add(quantity)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *PlayerCollectionHandler) Remove(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	quantity := func() int {
		v, ok := body["quantity"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.Remove(quantity)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *PlayerCollectionHandler) EstimatedValue(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerCollection
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerCollection"); return }
		handler.DbError(c, err); return
	}
	result, err := row.EstimatedValue()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validatePlayerCollection(req *model.PlayerCollectionCreateRequest) []string {
	var errs []string
	if !(req.Quantity > 0) {
		errs = append(errs, "Collection quantity must be greater than zero")
	}
	return errs
}

func toCreateRequestPlayerCollection(m *model.PlayerCollection) model.PlayerCollectionCreateRequest {
	return model.PlayerCollectionCreateRequest{
		Quantity: m.Quantity,
		Foil: m.Foil,
		Condition: m.Condition,
		AcquiredAt: m.AcquiredAt,
		AcquiredVia: m.AcquiredVia,
		PlayerID: m.PlayerID,
		CardID: m.CardID,
	}
}
