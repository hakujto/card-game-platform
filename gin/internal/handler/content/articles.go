package handler_content

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleHandler struct { db *gorm.DB }

func NewArticleHandler(db *gorm.DB) *ArticleHandler {
	return &ArticleHandler{db: db}
}

func (h *ArticleHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/articles")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/publish", h.Publish)
	g.POST("/:id/archive", h.Archive)
	g.POST("/:id/view", h.IncrementView)
}

func (h *ArticleHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Article
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.ArticleResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *ArticleHandler) Create(c *gin.Context) {
	var req model.ArticleCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	if msgs := validateArticle(&req); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	row := model.Article{}
	row.Title = req.Title
	row.Slug = req.Slug
	row.Body = req.Body
	row.Excerpt = req.Excerpt
	row.CoverImageUrl = req.CoverImageUrl
	row.Status = req.Status
	row.ArticleType = req.ArticleType
	row.ViewCount = req.ViewCount
	row.PublishedAt = req.PublishedAt
	row.AuthorID = req.AuthorID
	row.FeaturedDeckID = req.FeaturedDeckID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *ArticleHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	var req model.ArticleUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestArticle(&row)
	if msgs := validateArticle(&createReq); len(msgs) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"errors": msgs}); return
	}
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *ArticleHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Article{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *ArticleHandler) Publish(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	err := row.Publish()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ArticleHandler) Archive(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	err := row.Archive()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ArticleHandler) IncrementView(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	err := row.IncrementView()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func validateArticle(req *model.ArticleCreateRequest) []string {
	var errs []string
	if !((!( req.Status == model.ArticleStatusType_Published ) || (req.PublishedAt != nil))) {
		errs = append(errs, "Published article must have a published_at timestamp")
	}
	return errs
}

func toCreateRequestArticle(m *model.Article) model.ArticleCreateRequest {
	return model.ArticleCreateRequest{
		Title: m.Title,
		Slug: m.Slug,
		Body: m.Body,
		Excerpt: m.Excerpt,
		CoverImageUrl: m.CoverImageUrl,
		Status: m.Status,
		ArticleType: m.ArticleType,
		ViewCount: m.ViewCount,
		PublishedAt: m.PublishedAt,
		AuthorID: m.AuthorID,
		FeaturedDeckID: m.FeaturedDeckID,
	}
}
