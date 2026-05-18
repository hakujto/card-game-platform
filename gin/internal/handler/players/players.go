package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerHandler struct { db *gorm.DB }

func NewPlayerHandler(db *gorm.DB) *PlayerHandler {
	return &PlayerHandler{db: db}
}

func (h *PlayerHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/players")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/promote", h.Promote)
	g.POST("/:id/demote", h.Demote)
	g.POST("/:id/win", h.RecordWin)
	g.POST("/:id/loss", h.RecordLoss)
	g.GET("/:id/win-rate", h.WinRate)
	g.POST("/:id/verify", h.Verify)
	g.PATCH("/:id/rating", h.UpdateRating)
}

func (h *PlayerHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Player
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.PlayerResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *PlayerHandler) Create(c *gin.Context) {
	var req model.PlayerCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validatePlayer(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Player{}
	row.DisplayName = req.DisplayName
	row.Rank = req.Rank
	row.Rating = req.Rating
	row.PeakRating = req.PeakRating
	row.Bio = req.Bio
	row.CountryCode = req.CountryCode
	row.AvatarUrl = req.AvatarUrl
	row.PreferredFormat = req.PreferredFormat
	row.IsVerified = req.IsVerified
	row.LastActiveAt = req.LastActiveAt
	row.UserID = req.UserID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *PlayerHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	var req model.PlayerUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestPlayer(&row)
	if msgs := validatePlayer(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *PlayerHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Player{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *PlayerHandler) Promote(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	result, err := row.Promote()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *PlayerHandler) Demote(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	result, err := row.Demote()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *PlayerHandler) RecordWin(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	err := row.RecordWin()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *PlayerHandler) RecordLoss(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	err := row.RecordLoss()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *PlayerHandler) WinRate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	result, err := row.WinRate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *PlayerHandler) Verify(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	err := row.Verify()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *PlayerHandler) UpdateRating(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Player
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Player"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	delta := func() int {
		v, ok := body["delta"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.UpdateRating(delta)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validatePlayer(req *model.PlayerCreateRequest) []string {
	var errs []string
	if !((req.Rating >= 0 && req.Rating <= 9999)) {
		errs = append(errs, "Rating must be between 0 and 9999")
	}
	if !(req.PeakRating >= req.Rating) {
		errs = append(errs, "Peak rating must be greater than or equal to current rating")
	}
	if !(req.DisplayName != "") {
		errs = append(errs, "Display name must not be empty")
	}
	return errs
}

func toCreateRequestPlayer(m *model.Player) model.PlayerCreateRequest {
	return model.PlayerCreateRequest{
		DisplayName: m.DisplayName,
		Rank: m.Rank,
		Rating: m.Rating,
		PeakRating: m.PeakRating,
		Bio: m.Bio,
		CountryCode: m.CountryCode,
		AvatarUrl: m.AvatarUrl,
		PreferredFormat: m.PreferredFormat,
		IsVerified: m.IsVerified,
		LastActiveAt: m.LastActiveAt,
		UserID: m.UserID,
	}
}
