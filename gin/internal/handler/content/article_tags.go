package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleTagHandler struct { db *gorm.DB }

func NewArticleTagHandler(db *gorm.DB) *ArticleTagHandler {
	return &ArticleTagHandler{db: db}
}

func (h *ArticleTagHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/article_tags")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
}

func (h *ArticleTagHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleTag
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.ArticleTagResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *ArticleTagHandler) Create(c *gin.Context) {
	var req model.ArticleTagCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.ArticleTag{}
	row.Name = req.Name
	row.Slug = req.Slug
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *ArticleTagHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTag"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleTagHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTag"); return }
		handler.DbError(c, err); return
	}
	var req model.ArticleTagUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleTagHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *ArticleTagHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.ArticleTag{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "ArticleTag"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}
