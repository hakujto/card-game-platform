package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type SeasonHandler struct { db *gorm.DB }

func NewSeasonHandler(db *gorm.DB) *SeasonHandler {
	return &SeasonHandler{db: db}
}

func (h *SeasonHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/seasons")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/activate", h.Activate)
	g.POST("/:id/deactivate", h.Deactivate)
	g.POST("/:id/finalize", h.FinalizeRewards)
}

func (h *SeasonHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Season
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.SeasonResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *SeasonHandler) Create(c *gin.Context) {
	var req model.SeasonCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateSeason(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Season{}
	row.Name = req.Name
	row.StartDate = req.StartDate
	row.EndDate = req.EndDate
	row.Format = req.Format
	row.IsActive = req.IsActive
	row.RewardDescription = req.RewardDescription
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *SeasonHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *SeasonHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	var req model.SeasonUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestSeason(&row)
	if msgs := validateSeason(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *SeasonHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *SeasonHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Season{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *SeasonHandler) Activate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	err := row.Activate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *SeasonHandler) Deactivate(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	err := row.Deactivate()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *SeasonHandler) FinalizeRewards(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	err := row.FinalizeRewards()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateSeason(req *model.SeasonCreateRequest) []string {
	var errs []string
	if !(req.EndDate > req.StartDate) {
		errs = append(errs, "Season end date must be after start date")
	}
	return errs
}

func toCreateRequestSeason(m *model.Season) model.SeasonCreateRequest {
	return model.SeasonCreateRequest{
		Name: m.Name,
		StartDate: m.StartDate,
		EndDate: m.EndDate,
		Format: m.Format,
		IsActive: m.IsActive,
		RewardDescription: m.RewardDescription,
	}
}
