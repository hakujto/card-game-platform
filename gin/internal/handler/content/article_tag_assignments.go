package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleTagAssignmentHandler struct { db *gorm.DB }

func NewArticleTagAssignmentHandler(db *gorm.DB) *ArticleTagAssignmentHandler {
	return &ArticleTagAssignmentHandler{db: db}
}

func (h *ArticleTagAssignmentHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/article_tag_assignments")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *ArticleTagAssignmentHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleTagAssignment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.ArticleTagAssignmentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *ArticleTagAssignmentHandler) Create(c *gin.Context) {
	var req model.ArticleTagAssignmentCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.ArticleTagAssignment{}
	row.ArticleID = req.ArticleID
	row.TagID = req.TagID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *ArticleTagAssignmentHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTagAssignment"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleTagAssignmentHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTagAssignment"); return }
		handler.DbError(c, err); return
	}
	var req model.ArticleTagAssignmentUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleTagAssignmentHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *ArticleTagAssignmentHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.ArticleTagAssignment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTagAssignment"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
