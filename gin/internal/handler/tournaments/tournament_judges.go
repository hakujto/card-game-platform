package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentJudgeHandler struct { db *gorm.DB }

func NewTournamentJudgeHandler(db *gorm.DB) *TournamentJudgeHandler {
	return &TournamentJudgeHandler{db: db}
}

func (h *TournamentJudgeHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tournament_judges")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/tournament-judges/{id}/promote", h.PromoteToHead)
	g.DELETE("/:id/api/tournament-judges/{id}", h.Remove)
}

func (h *TournamentJudgeHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentJudge
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TournamentJudgeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TournamentJudgeHandler) Create(c *gin.Context) {
	var req model.TournamentJudgeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.TournamentJudge{}
	row.Role = req.Role
	row.TournamentID = req.TournamentID
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TournamentJudgeHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentJudge"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentJudgeHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentJudge"); return }
		handler.DbError(c, err); return
	}
	var req model.TournamentJudgeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentJudgeHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TournamentJudgeHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TournamentJudge{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentJudge"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TournamentJudgeHandler) PromoteToHead(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentJudge"); return }
		handler.DbError(c, err); return
	}
	err := row.PromoteToHead()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentJudgeHandler) Remove(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentJudge
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentJudge"); return }
		handler.DbError(c, err); return
	}
	err := row.Remove()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
