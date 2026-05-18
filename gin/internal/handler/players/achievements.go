package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type AchievementHandler struct { db *gorm.DB }

func NewAchievementHandler(db *gorm.DB) *AchievementHandler {
	return &AchievementHandler{db: db}
}

func (h *AchievementHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/achievements")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.GET("/:id/point-value", h.PointValue)
	g.POST("/:id/reveal", h.Reveal)
}

func (h *AchievementHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Achievement
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.AchievementResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *AchievementHandler) Create(c *gin.Context) {
	var req model.AchievementCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateAchievement(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Achievement{}
	row.Name = req.Name
	row.Description = req.Description
	row.IconUrl = req.IconUrl
	row.Points = req.Points
	row.Rarity = req.Rarity
	row.IsHidden = req.IsHidden
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *AchievementHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Achievement"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *AchievementHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Achievement"); return }
		handler.DbError(c, err); return
	}
	var req model.AchievementUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestAchievement(&row)
	if msgs := validateAchievement(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *AchievementHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *AchievementHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Achievement{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Achievement"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *AchievementHandler) PointValue(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Achievement"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	multiplier := func() int {
		v, ok := body["multiplier"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	result, err := row.PointValue(multiplier)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *AchievementHandler) Reveal(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Achievement
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Achievement"); return }
		handler.DbError(c, err); return
	}
	err := row.Reveal()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateAchievement(req *model.AchievementCreateRequest) []string {
	var errs []string
	if !(req.Points > 0) {
		errs = append(errs, "Achievement must award at least one point")
	}
	return errs
}

func toCreateRequestAchievement(m *model.Achievement) model.AchievementCreateRequest {
	return model.AchievementCreateRequest{
		Name: m.Name,
		Description: m.Description,
		IconUrl: m.IconUrl,
		Points: m.Points,
		Rarity: m.Rarity,
		IsHidden: m.IsHidden,
	}
}
