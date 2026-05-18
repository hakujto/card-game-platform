package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type AwardedPrizeHandler struct { db *gorm.DB }

func NewAwardedPrizeHandler(db *gorm.DB) *AwardedPrizeHandler {
	return &AwardedPrizeHandler{db: db}
}

func (h *AwardedPrizeHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/awarded_prizes")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/awarded-prizes/{id}/claim", h.Claim)
}

func (h *AwardedPrizeHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.AwardedPrize
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.AwardedPrizeResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *AwardedPrizeHandler) Create(c *gin.Context) {
	var req model.AwardedPrizeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateAwardedPrize(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.AwardedPrize{}
	row.FinalPlacement = req.FinalPlacement
	row.AwardedAt = req.AwardedAt
	row.Claimed = req.Claimed
	row.ClaimedAt = req.ClaimedAt
	row.PrizeID = req.PrizeID
	row.PlayerID = req.PlayerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *AwardedPrizeHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "AwardedPrize"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *AwardedPrizeHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "AwardedPrize"); return }
		handler.DbError(c, err); return
	}
	var req model.AwardedPrizeUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestAwardedPrize(&row)
	if msgs := validateAwardedPrize(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *AwardedPrizeHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *AwardedPrizeHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.AwardedPrize{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "AwardedPrize"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *AwardedPrizeHandler) Claim(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "AwardedPrize"); return }
		handler.DbError(c, err); return
	}
	err := row.Claim()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *AwardedPrizeHandler) SetClaimed(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var body struct{ Value bool `json:"value"` }
	if err := c.ShouldBindJSON(&body); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	var row model.AwardedPrize
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "AwardedPrize"); return }
		handler.DbError(c, err); return
	}
	row.Claimed = body.Value
	if row.Claimed == true {
		_ = row.Claim() // @on(claimed = true)
	}
	h.db.Save(&row)
	c.JSON(http.StatusOK, row.ToResponse())
}

func validateAwardedPrize(req *model.AwardedPrizeCreateRequest) []string {
	var errs []string
	if !((!( req.Claimed ) || (req.ClaimedAt != nil))) {
		errs = append(errs, "Claimed prize must have a claimed_at timestamp")
	}
	if !(req.FinalPlacement > 0) {
		errs = append(errs, "Final placement must be greater than zero")
	}
	return errs
}

func toCreateRequestAwardedPrize(m *model.AwardedPrize) model.AwardedPrizeCreateRequest {
	return model.AwardedPrizeCreateRequest{
		FinalPlacement: m.FinalPlacement,
		AwardedAt: m.AwardedAt,
		Claimed: m.Claimed,
		ClaimedAt: m.ClaimedAt,
		PrizeID: m.PrizeID,
		PlayerID: m.PlayerID,
	}
}
