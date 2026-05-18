package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerAchievementHandler struct { db *gorm.DB }

func NewPlayerAchievementHandler(db *gorm.DB) *PlayerAchievementHandler {
	return &PlayerAchievementHandler{db: db}
}

func (h *PlayerAchievementHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/player_achievements")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *PlayerAchievementHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerAchievement
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.PlayerAchievementResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *PlayerAchievementHandler) Create(c *gin.Context) {
	var req model.PlayerAchievementCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validatePlayerAchievement(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.PlayerAchievement{}
	row.EarnedAt = req.EarnedAt
	row.Progress = req.Progress
	row.IsCompleted = req.IsCompleted
	row.PlayerID = req.PlayerID
	row.AchievementID = req.AchievementID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *PlayerAchievementHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerAchievement"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerAchievementHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerAchievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerAchievement"); return }
		handler.DbError(c, err); return
	}
	var req model.PlayerAchievementUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestPlayerAchievement(&row)
	if msgs := validatePlayerAchievement(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerAchievementHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *PlayerAchievementHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.PlayerAchievement{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerAchievement"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func validatePlayerAchievement(req *model.PlayerAchievementCreateRequest) []string {
	var errs []string
	if !((!( req.IsCompleted ) || (req.Progress > 0))) {
		errs = append(errs, "Completed achievement must have progress greater than zero")
	}
	return errs
}

func toCreateRequestPlayerAchievement(m *model.PlayerAchievement) model.PlayerAchievementCreateRequest {
	return model.PlayerAchievementCreateRequest{
		EarnedAt: m.EarnedAt,
		Progress: m.Progress,
		IsCompleted: m.IsCompleted,
		PlayerID: m.PlayerID,
		AchievementID: m.AchievementID,
	}
}
