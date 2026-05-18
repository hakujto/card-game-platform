package handler_tournaments

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/tournaments"
	"cards_project/internal/handler"
)

type TournamentHandler struct { db *gorm.DB }

func NewTournamentHandler(db *gorm.DB) *TournamentHandler {
	return &TournamentHandler{db: db}
}

func (h *TournamentHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/tournaments")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/start", h.Start)
	g.POST("/:id/cancel", h.Cancel)
	g.POST("/:id/complete", h.Complete)
	g.POST("/:id/rounds", h.GenerateRound)
	g.GET("/:id/prizes", h.CalculatePrizeDistribution)
}

func (h *TournamentHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Tournament
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.TournamentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *TournamentHandler) Create(c *gin.Context) {
	var req model.TournamentCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateTournament(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Tournament{}
	row.Name = req.Name
	row.Description = req.Description
	row.Format = req.Format
	row.TournamentType = req.TournamentType
	row.Status = req.Status
	row.MaxPlayers = req.MaxPlayers
	row.EntryFee = req.EntryFee
	row.PrizePool = req.PrizePool
	row.StartTime = req.StartTime
	row.EndTime = req.EndTime
	row.IsOnline = req.IsOnline
	row.Location = req.Location
	row.RulesText = req.RulesText
	row.SeasonID = req.SeasonID
	row.OrganizerID = req.OrganizerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *TournamentHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	var req model.TournamentUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestTournament(&row)
	if msgs := validateTournament(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *TournamentHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *TournamentHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Tournament{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *TournamentHandler) Start(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	err := row.Start()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentHandler) Cancel(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	err := row.Cancel()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentHandler) Complete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	err := row.Complete()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentHandler) GenerateRound(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	err := row.GenerateRound()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *TournamentHandler) CalculatePrizeDistribution(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Tournament
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Tournament"); return }
		handler.DbError(c, err); return
	}
	result, err := row.CalculatePrizeDistribution()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateTournament(req *model.TournamentCreateRequest) []string {
	var errs []string
	if !((req.MaxPlayers >= 2 && req.MaxPlayers <= 512)) {
		errs = append(errs, "Tournament must allow between 2 and 512 players")
	}
	if !(float64(req.EntryFee) >= 0) {
		errs = append(errs, "Entry fee must not be negative")
	}
	if !(float64(req.PrizePool) >= 0) {
		errs = append(errs, "Prize pool must not be negative")
	}
	if !((!( req.EndTime != nil ) || (*req.EndTime > req.StartTime))) {
		errs = append(errs, "End time must be after start time")
	}
	return errs
}

func toCreateRequestTournament(m *model.Tournament) model.TournamentCreateRequest {
	return model.TournamentCreateRequest{
		Name: m.Name,
		Description: m.Description,
		Format: m.Format,
		TournamentType: m.TournamentType,
		Status: m.Status,
		MaxPlayers: m.MaxPlayers,
		EntryFee: m.EntryFee,
		PrizePool: m.PrizePool,
		StartTime: m.StartTime,
		EndTime: m.EndTime,
		IsOnline: m.IsOnline,
		Location: m.Location,
		RulesText: m.RulesText,
		SeasonID: m.SeasonID,
		OrganizerID: m.OrganizerID,
	}
}
