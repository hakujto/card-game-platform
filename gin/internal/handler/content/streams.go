package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type StreamHandler struct { db *gorm.DB }

func NewStreamHandler(db *gorm.DB) *StreamHandler {
	return &StreamHandler{db: db}
}

func (h *StreamHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/streams")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/live", h.GoLive)
	g.POST("/:id/end", h.End)
	g.PATCH("/:id/viewers", h.UpdateViewerPeak)
	g.GET("/:id/duration", h.DurationMinutes)
}

func (h *StreamHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Stream
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.StreamResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *StreamHandler) Create(c *gin.Context) {
	var req model.StreamCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateStream(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Stream{}
	row.Title = req.Title
	row.StreamUrl = req.StreamUrl
	row.Platform = req.Platform
	row.Status = req.Status
	row.ViewerCountPeak = req.ViewerCountPeak
	row.ScheduledStart = req.ScheduledStart
	row.ActualStart = req.ActualStart
	row.EndedAt = req.EndedAt
	row.VodUrl = req.VodUrl
	row.TournamentID = req.TournamentID
	row.StreamerID = req.StreamerID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *StreamHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *StreamHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	var req model.StreamUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestStream(&row)
	if msgs := validateStream(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *StreamHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *StreamHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Stream{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *StreamHandler) GoLive(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	err := row.GoLive()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *StreamHandler) End(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	err := row.End()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *StreamHandler) UpdateViewerPeak(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	var body map[string]interface{}
	_ = c.ShouldBindJSON(&body)
	count := func() int {
		v, ok := body["count"]; if !ok { return 0 }
		f, ok := v.(float64); if !ok { return 0 }
		return int(f)
	}()
	err := row.UpdateViewerPeak(count)
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *StreamHandler) DurationMinutes(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Stream
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Stream"); return }
		handler.DbError(c, err); return
	}
	result, err := row.DurationMinutes()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func validateStream(req *model.StreamCreateRequest) []string {
	var errs []string
	if !((!( req.ActualStart != nil ) || (req.Status == model.StreamStatusType_Live))) {
		errs = append(errs, "actual_start_requires_live_or_ended")
	}
	if !((!( req.EndedAt != nil ) || (req.Status == model.StreamStatusType_Ended))) {
		errs = append(errs, "ended_at can only be set when stream status is Ended")
	}
	if !(req.ViewerCountPeak >= 0) {
		errs = append(errs, "Peak viewer count must not be negative")
	}
	return errs
}

func toCreateRequestStream(m *model.Stream) model.StreamCreateRequest {
	return model.StreamCreateRequest{
		Title: m.Title,
		StreamUrl: m.StreamUrl,
		Platform: m.Platform,
		Status: m.Status,
		ViewerCountPeak: m.ViewerCountPeak,
		ScheduledStart: m.ScheduledStart,
		ActualStart: m.ActualStart,
		EndedAt: m.EndedAt,
		VodUrl: m.VodUrl,
		TournamentID: m.TournamentID,
		StreamerID: m.StreamerID,
	}
}
