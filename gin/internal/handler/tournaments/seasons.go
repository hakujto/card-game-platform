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
	g.POST("/:id/activate", h.Activate)
	g.POST("/:id/deactivate", h.Deactivate)
	g.POST("/:id/finalize", h.FinalizeRewards)
	g.GET("/:id/ongoing", h.IsOngoing)
}

func (h *SeasonHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Season
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
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
		if handler.IsUniqueViolation(err) { handler.UnprocessableError(c, "Value must be unique"); return }
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
		if handler.IsUniqueViolation(err) { handler.UnprocessableError(c, "Value must be unique"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *SeasonHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *SeasonHandler) Activate(c *gin.Context) {
	userRole, _ := c.Get("user_role")
	allowedRolesActivate := []string{"admin"}
	roleOkActivate := false
	for _, r := range allowedRolesActivate { if r == userRole { roleOkActivate = true; break } }
	if !roleOkActivate { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for activate"}); return }
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
	userRole, _ := c.Get("user_role")
	allowedRolesDeactivate := []string{"admin"}
	roleOkDeactivate := false
	for _, r := range allowedRolesDeactivate { if r == userRole { roleOkDeactivate = true; break } }
	if !roleOkDeactivate { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for deactivate"}); return }
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
	userRole, _ := c.Get("user_role")
	allowedRolesFinalizeRewards := []string{"admin"}
	roleOkFinalizeRewards := false
	for _, r := range allowedRolesFinalizeRewards { if r == userRole { roleOkFinalizeRewards = true; break } }
	if !roleOkFinalizeRewards { c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient role for finalize_rewards"}); return }
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

func (h *SeasonHandler) IsOngoing(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Season
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Season"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsOngoing()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
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
