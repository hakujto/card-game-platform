package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleCommentHandler struct { db *gorm.DB }

func NewArticleCommentHandler(db *gorm.DB) *ArticleCommentHandler {
	return &ArticleCommentHandler{db: db}
}

func (h *ArticleCommentHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/article_comments")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/api/comments/{id}/hide", h.Hide)
	g.POST("/:id/api/comments/{id}/unhide", h.Unhide)
}

func (h *ArticleCommentHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleComment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.ArticleCommentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *ArticleCommentHandler) Create(c *gin.Context) {
	var req model.ArticleCommentCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.ArticleComment{}
	row.Body = req.Body
	row.IsHidden = req.IsHidden
	row.ArticleID = req.ArticleID
	row.AuthorID = req.AuthorID
	row.ParentCommentID = req.ParentCommentID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *ArticleCommentHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleComment"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleCommentHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleComment"); return }
		handler.DbError(c, err); return
	}
	var req model.ArticleCommentUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleCommentHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *ArticleCommentHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.ArticleComment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleComment"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *ArticleCommentHandler) Hide(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleComment"); return }
		handler.DbError(c, err); return
	}
	err := row.Hide()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ArticleCommentHandler) Unhide(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleComment"); return }
		handler.DbError(c, err); return
	}
	err := row.Unhide()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
