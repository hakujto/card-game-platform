package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type GameHandler struct { db *gorm.DB }

func NewGameHandler(db *gorm.DB) *GameHandler {
	return &GameHandler{db: db}
}

func (h *GameHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/games")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/winner", h.RecordWinner)
}

func (h *GameHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Game
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.GameResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *GameHandler) Create(c *gin.Context) {
	var req model.GameCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateGame(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Game{}
	row.GameNumber = req.GameNumber
	row.WinnerSide = req.WinnerSide
	row.TurnsPlayed = req.TurnsPlayed
	row.DurationSeconds = req.DurationSeconds
	row.EndedBy = req.EndedBy
	row.ReplayUrl = req.ReplayUrl
	row.MatchID = req.MatchID
	row.WinnerID = req.WinnerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *GameHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Game"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *GameHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Game"); return }
		handler.DbError(c, err); return
	}
	var req model.GameUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestGame(&row)
	if msgs := validateGame(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *GameHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *GameHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Game{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Game"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *GameHandler) RecordWinner(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Game
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Game"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	winnerSide := func() string {
		v, ok := body["winner_side"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.RecordWinner(winnerSide)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateGame(req *model.GameCreateRequest) []string {
	var errs []string
	if !((req.GameNumber >= 1 && req.GameNumber <= 3)) {
		errs = append(errs, "Game number must be between 1 and 3 (best-of-3)")
	}
	if !((!( req.TurnsPlayed != nil ) || (*req.TurnsPlayed > 0))) {
		errs = append(errs, "Turns played must be greater than zero")
	}
	if !((!( req.DurationSeconds != nil ) || (*req.DurationSeconds > 0))) {
		errs = append(errs, "Game duration must be greater than zero")
	}
	return errs
}

func toCreateRequestGame(m *model.Game) model.GameCreateRequest {
	return model.GameCreateRequest{
		GameNumber: m.GameNumber,
		WinnerSide: m.WinnerSide,
		TurnsPlayed: m.TurnsPlayed,
		DurationSeconds: m.DurationSeconds,
		EndedBy: m.EndedBy,
		ReplayUrl: m.ReplayUrl,
		MatchID: m.MatchID,
		WinnerID: m.WinnerID,
	}
}
