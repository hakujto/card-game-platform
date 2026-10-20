package handler_players

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type PlayerSeasonStatsHandler struct { db *gorm.DB }

func NewPlayerSeasonStatsHandler(db *gorm.DB) *PlayerSeasonStatsHandler {
	return &PlayerSeasonStatsHandler{db: db}
}

func (h *PlayerSeasonStatsHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/player_season_statses")
	g.Get("", h.List)
	g.Get("/:id", h.Get)
	g.Get("/:id/api/player-season-stats/{id}/win-rate", h.WinRate)
	g.Patch("/:id/api/player-season-stats/{id}/points", h.AddPoints)
	g.Post("/:id/api/player-season-stats/{id}/tournament-win", h.RecordTournamentWin)
}

func (h *PlayerSeasonStatsHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.PlayerSeasonStats
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.PlayerSeasonStatsResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *PlayerSeasonStatsHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerSeasonStats") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *PlayerSeasonStatsHandler) WinRate(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerSeasonStats") }
		return handler.DbError(c, err)
	}
	result, err := row.WinRate()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *PlayerSeasonStatsHandler) AddPoints(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerSeasonStats") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	points := func() int {
		v, ok := body["points"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.AddPoints(points)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *PlayerSeasonStatsHandler) RecordTournamentWin(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.PlayerSeasonStats
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "PlayerSeasonStats") }
		return handler.DbError(c, err)
	}
	err := row.RecordTournamentWin()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Validation rules ─────────────────────────────────────────────
func validatePlayerSeasonStats(req *model.PlayerSeasonStatsCreateRequest) []string {
	var errs []string
	if !(req.Wins >= 0) {
		errs = append(errs, "Season wins must not be negative")
	}
	if !(req.Losses >= 0) {
		errs = append(errs, "Season losses must not be negative")
	}
	if !(req.TournamentWins >= 0) {
		errs = append(errs, "Season tournament wins must not be negative")
	}
	if !(req.SeasonPoints >= 0) {
		errs = append(errs, "Season points must not be negative")
	}
	return errs
}

func toCreateRequestPlayerSeasonStats(m *model.PlayerSeasonStats) model.PlayerSeasonStatsCreateRequest {
	return model.PlayerSeasonStatsCreateRequest{
		Wins: m.Wins,
		Losses: m.Losses,
		Draws: m.Draws,
		TournamentWins: m.TournamentWins,
		HighestRank: m.HighestRank,
		SeasonPoints: m.SeasonPoints,
		PlayerID: m.PlayerID,
		SeasonID: m.SeasonID,
	}
}
