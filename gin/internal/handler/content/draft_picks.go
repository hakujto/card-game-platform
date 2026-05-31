package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type DraftPickHandler struct { db *gorm.DB }

func NewDraftPickHandler(db *gorm.DB) *DraftPickHandler {
	return &DraftPickHandler{db: db}
}

func (h *DraftPickHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/draft_picks")
	g.GET("", h.List)
	g.GET("/:id", h.Get)
	g.GET("/:id/api/draft-picks/{id}/first-pick", h.IsFirstPick)
}

func (h *DraftPickHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.DraftPick
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.DraftPickResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *DraftPickHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftPick"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *DraftPickHandler) IsFirstPick(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.DraftPick
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "DraftPick"); return }
		handler.DbError(c, err); return
	}
	result, err := row.IsFirstPick()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

// ── Validation rules ─────────────────────────────────────────────
func validateDraftPick(req *model.DraftPickCreateRequest) []string {
	var errs []string
	if !(req.PickNumber > 0) {
		errs = append(errs, "Pick number must be greater than zero")
	}
	if !((req.PackNumber >= 1 && req.PackNumber <= 3)) {
		errs = append(errs, "Pack number must be between 1 and 3")
	}
	return errs
}

func toCreateRequestDraftPick(m *model.DraftPick) model.DraftPickCreateRequest {
	return model.DraftPickCreateRequest{
		PickNumber: m.PickNumber,
		PackNumber: m.PackNumber,
		PickedAt: m.PickedAt,
		ParticipantID: m.ParticipantID,
		CardID: m.CardID,
	}
}
