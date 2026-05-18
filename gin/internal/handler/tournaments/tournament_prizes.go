package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentPrizeHandler struct { db *gorm.DB }

func NewTournamentPrizeHandler(db *gorm.DB) *TournamentPrizeHandler {
	return &TournamentPrizeHandler{db: db}
}

func (h *TournamentPrizeHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tournament_prizes")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/api/prizes/{id}/applies", h.AppliesToPlacement)
	g.POST("/:id/api/prizes/{id}/award", h.AwardToPlayer)
}

func (h *TournamentPrizeHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentPrize
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TournamentPrizeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TournamentPrizeHandler) Create(c *gin.Context) {
	var req model.TournamentPrizeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTournamentPrize(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.TournamentPrize{}
	row.PlacementFrom = req.PlacementFrom
	row.PlacementTo = req.PlacementTo
	row.PrizeType = req.PrizeType
	row.Amount = req.Amount
	row.Description = req.Description
	row.PacksCount = req.PacksCount
	row.SeasonPoints = req.SeasonPoints
	row.TournamentID = req.TournamentID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TournamentPrizeHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentPrize"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentPrizeHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentPrize"); return }
		handler.DbError(c, err); return
	}
	var req model.TournamentPrizeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournamentPrize(&row)
	if msgs := validateTournamentPrize(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentPrizeHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TournamentPrizeHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TournamentPrize{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentPrize"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TournamentPrizeHandler) AppliesToPlacement(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentPrize"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	placement := func() int {
		v, ok := body["placement"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.AppliesToPlacement(placement)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *TournamentPrizeHandler) AwardToPlayer(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentPrize"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	playerId := func() int {
		v, ok := body["player_id"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.AwardToPlayer(playerId)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateTournamentPrize(req *model.TournamentPrizeCreateRequest) []string {
	var errs []string
	if !(req.PlacementTo >= req.PlacementFrom) {
		errs = append(errs, "placement_to must be greater than or equal to placement_from")
	}
	if !(req.PlacementFrom > 0) {
		errs = append(errs, "placement_from must be greater than zero")
	}
	if !(float64(req.Amount) >= 0) {
		errs = append(errs, "Prize amount must not be negative")
	}
	return errs
}

func toCreateRequestTournamentPrize(m *model.TournamentPrize) model.TournamentPrizeCreateRequest {
	return model.TournamentPrizeCreateRequest{
		PlacementFrom: m.PlacementFrom,
		PlacementTo: m.PlacementTo,
		PrizeType: m.PrizeType,
		Amount: m.Amount,
		Description: m.Description,
		PacksCount: m.PacksCount,
		SeasonPoints: m.SeasonPoints,
		TournamentID: m.TournamentID,
	}
}
