package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentRegistrationHandler struct { db *gorm.DB }

func NewTournamentRegistrationHandler(db *gorm.DB) *TournamentRegistrationHandler {
	return &TournamentRegistrationHandler{db: db}
}

func (h *TournamentRegistrationHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tournament_registrations")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/registrations/{id}/withdraw", h.Withdraw)
	g.POST("/:id/api/registrations/{id}/disqualify", h.Disqualify)
	g.POST("/:id/api/registrations/{id}/promote", h.PromoteFromWaitlist)
}

func (h *TournamentRegistrationHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.TournamentRegistration
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TournamentRegistrationResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TournamentRegistrationHandler) Create(c *gin.Context) {
	var req model.TournamentRegistrationCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTournamentRegistration(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.TournamentRegistration{}
	row.Status = req.Status
	row.Seed = req.Seed
	row.FinalStanding = req.FinalStanding
	row.PointsEarned = req.PointsEarned
	row.RegisteredAt = req.RegisteredAt
	row.TournamentID = req.TournamentID
	row.PlayerID = req.PlayerID
	row.DeckID = req.DeckID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TournamentRegistrationHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentRegistrationHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	var req model.TournamentRegistrationUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournamentRegistration(&row)
	if msgs := validateTournamentRegistration(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentRegistrationHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TournamentRegistrationHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.TournamentRegistration{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TournamentRegistrationHandler) Withdraw(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	err := row.Withdraw()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentRegistrationHandler) Disqualify(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	reason := func() string {
		v, ok := body["reason"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Disqualify(reason)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentRegistrationHandler) PromoteFromWaitlist(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.TournamentRegistration
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "TournamentRegistration"); return }
		handler.DbError(c, err); return
	}
	err := row.PromoteFromWaitlist()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateTournamentRegistration(req *model.TournamentRegistrationCreateRequest) []string {
	var errs []string
	if !(req.PointsEarned >= 0) {
		errs = append(errs, "Points earned must not be negative")
	}
	if !((!( req.FinalStanding != nil ) || (*req.FinalStanding > 0))) {
		errs = append(errs, "Final standing must be greater than zero")
	}
	if !((!( req.Seed != nil ) || (*req.Seed > 0))) {
		errs = append(errs, "Seed must be greater than zero")
	}
	return errs
}

func toCreateRequestTournamentRegistration(m *model.TournamentRegistration) model.TournamentRegistrationCreateRequest {
	return model.TournamentRegistrationCreateRequest{
		Status: m.Status,
		Seed: m.Seed,
		FinalStanding: m.FinalStanding,
		PointsEarned: m.PointsEarned,
		RegisteredAt: m.RegisteredAt,
		TournamentID: m.TournamentID,
		PlayerID: m.PlayerID,
		DeckID: m.DeckID,
	}
}
