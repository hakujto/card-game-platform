package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerSeasonStatsHandler struct { db *gorm.DB }

func NewPlayerSeasonStatsHandler(db *gorm.DB) *PlayerSeasonStatsHandler {
	return &PlayerSeasonStatsHandler{db: db}
}

func (h *PlayerSeasonStatsHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/player_season_statses")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *PlayerSeasonStatsHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerSeasonStats
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.PlayerSeasonStatsResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *PlayerSeasonStatsHandler) Create(c *gin.Context) {
	var req model.PlayerSeasonStatsCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.PlayerSeasonStats{}
	row.Wins = req.Wins
	row.Losses = req.Losses
	row.Draws = req.Draws
	row.TournamentWins = req.TournamentWins
	row.HighestRank = req.HighestRank
	row.SeasonPoints = req.SeasonPoints
	row.PlayerID = req.PlayerID
	row.SeasonID = req.SeasonID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *PlayerSeasonStatsHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerSeasonStats"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerSeasonStatsHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerSeasonStats"); return }
		handler.DbError(c, err); return
	}
	var req model.PlayerSeasonStatsUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *PlayerSeasonStatsHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *PlayerSeasonStatsHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.PlayerSeasonStats{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "PlayerSeasonStats"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
