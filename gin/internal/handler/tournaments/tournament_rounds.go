package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentRoundHandler struct { db *gorm.DB }

func NewTournamentRoundHandler(db *gorm.DB) *TournamentRoundHandler {
	return &TournamentRoundHandler{db: db}
}

func (h *TournamentRoundHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tournament_rounds")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/rounds/{id}/start", h.Start)
	g.POST("/:id/api/rounds/{id}/complete", h.Complete)
	g.POST("/:id/api/rounds/{id}/pairings", h.GeneratePairings)
}

func (h *TournamentRoundHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentRound
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TournamentRoundResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TournamentRoundHandler) Create(c *gin.Context) {
	var req model.TournamentRoundCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTournamentRound(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.TournamentRound{}
	row.RoundNumber = req.RoundNumber
	row.Status = req.Status
	row.StartedAt = req.StartedAt
	row.EndedAt = req.EndedAt
	row.TimeLimitMinutes = req.TimeLimitMinutes
	row.TournamentID = req.TournamentID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TournamentRoundHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentRoundHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	var req model.TournamentRoundUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournamentRound(&row)
	if msgs := validateTournamentRound(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentRoundHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TournamentRoundHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TournamentRound{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TournamentRoundHandler) Start(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	err := row.Start()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentRoundHandler) Complete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	err := row.Complete()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentRoundHandler) GeneratePairings(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRound
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRound"); return }
		handler.DbError(c, err); return
	}
	err := row.GeneratePairings()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateTournamentRound(req *model.TournamentRoundCreateRequest) []string {
	var errs []string
	if !((!( req.EndedAt != nil ) || ((req.StartedAt != nil && *req.EndedAt > *req.StartedAt)))) {
		errs = append(errs, "Round end time must be after start time")
	}
	return errs
}

func toCreateRequestTournamentRound(m *model.TournamentRound) model.TournamentRoundCreateRequest {
	return model.TournamentRoundCreateRequest{
		RoundNumber: m.RoundNumber,
		Status: m.Status,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		TimeLimitMinutes: m.TimeLimitMinutes,
		TournamentID: m.TournamentID,
	}
}
