package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type MatchHandler struct { db *gorm.DB }

func NewMatchHandler(db *gorm.DB) *MatchHandler {
	return &MatchHandler{db: db}
}

func (h *MatchHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/matches")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/record", h.RecordResult)
	g.GET("/:id/winner", h.DetermineWinner)
	g.POST("/:id/draw", h.Draw)
}

func (h *MatchHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Match
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.MatchResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *MatchHandler) Create(c *gin.Context) {
	var req model.MatchCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateMatch(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Match{}
	row.TableNumber = req.TableNumber
	row.Status = req.Status
	row.Player1Wins = req.Player1Wins
	row.Player2Wins = req.Player2Wins
	row.StartedAt = req.StartedAt
	row.EndedAt = req.EndedAt
	row.ResultNotes = req.ResultNotes
	row.RoundID = req.RoundID
	row.Player1ID = req.Player1ID
	row.Player2ID = req.Player2ID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *MatchHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *MatchHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	var req model.MatchUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestMatch(&row)
	if msgs := validateMatch(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *MatchHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *MatchHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Match{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *MatchHandler) RecordResult(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	p1Wins := func() int {
		v, ok := body["p1_wins"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	p2Wins := func() int {
		v, ok := body["p2_wins"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.RecordResult(p1Wins, p2Wins)
	if err != nil { handler.DbError(c, err); return }
	_, _ = row.DetermineWinner() // @after
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *MatchHandler) DetermineWinner(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	result, err := row.DetermineWinner()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *MatchHandler) Draw(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Match
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Match"); return }
		handler.DbError(c, err); return
	}
	err := row.Draw()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateMatch(req *model.MatchCreateRequest) []string {
	var errs []string
	if !((req.Player1Wins >= 0 && req.Player2Wins >= 0)) {
		errs = append(errs, "Win counts must not be negative")
	}
	if !(((req.Player1Wins >= 0 && req.Player1Wins <= 2) && (req.Player2Wins >= 0 && req.Player2Wins <= 2))) {
		errs = append(errs, "Win counts cannot exceed 2 in a best-of-3 match")
	}
	if !((!( req.Status == model.MatchStatusType_BYE ) || (req.Player2ID == nil))) {
		errs = append(errs, "BYE match must not have a second player")
	}
	return errs
}

func toCreateRequestMatch(m *model.Match) model.MatchCreateRequest {
	return model.MatchCreateRequest{
		TableNumber: m.TableNumber,
		Status: m.Status,
		Player1Wins: m.Player1Wins,
		Player2Wins: m.Player2Wins,
		StartedAt: m.StartedAt,
		EndedAt: m.EndedAt,
		ResultNotes: m.ResultNotes,
		RoundID: m.RoundID,
		Player1ID: m.Player1ID,
		Player2ID: m.Player2ID,
	}
}
