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
	g.POST("/:id/publish", h.Publish)
	g.POST("/:id/archive", h.Archive)
	g.POST("/:id/view", h.IncrementView)
	g.POST("/:id/like", h.Like)
	g.DELETE("/:id/like", h.Unlike)
	g.GET("/:id/reading-time", h.ReadingTimeMinutes)
	g.PATCH("/:id/transitions/draft-to-published", h.TransitionDraftToPublished)
	g.PATCH("/:id/transitions/published-to-archived", h.TransitionPublishedToArchived)
	g.PATCH("/:id/transitions/archived-to-draft", h.TransitionArchivedToDraft)
	g.PATCH("/:id/transitions/published-to-draft", h.TransitionPublishedToDraft)
}

func (h *ArticleHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Article
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("title LIKE ?", "%"+q+"%")
		db = db.Or("excerpt LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
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
	row.Language = req.Language
	row.ViewCount = req.ViewCount
	row.LikesCount = req.LikesCount
	row.IsFeatured = req.IsFeatured
	row.PublishedAt = req.PublishedAt
	row.AuthorID = req.AuthorID
	row.FeaturedDeckID = req.FeaturedDeckID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { handler.UnprocessableError(c, "Value must be unique"); return }
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
		if handler.IsUniqueViolation(err) { handler.UnprocessableError(c, "Value must be unique"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) Patch(c *gin.Context) { h.Update(c) }

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

func (h *ArticleHandler) Like(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	err := row.Like()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ArticleHandler) Unlike(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	err := row.Unlike()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *ArticleHandler) ReadingTimeMinutes(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	result, err := row.ReadingTimeMinutes()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (h *ArticleHandler) TransitionDraftToPublished(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	if err := row.AssertTransition("Published"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	if row.Title == "" {
		handler.UnprocessableError(c, "title is required for this transition"); return
	}
	if row.Body == "" {
		handler.UnprocessableError(c, "body is required for this transition"); return
	}
	row.Status = model.ArticleStatusType_Published
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.Publish() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) TransitionPublishedToArchived(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	if err := row.AssertTransition("Archived"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	row.Status = model.ArticleStatusType_Archived
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	_ = row.Archive() // @after
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) TransitionArchivedToDraft(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	if err := row.AssertTransition("Draft"); err != nil {
		handler.ConflictError(c, err.Error()); return
	}
	row.Status = model.ArticleStatusType_Draft
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *ArticleHandler) TransitionPublishedToDraft(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Article"); return }
		handler.DbError(c, err); return
	}
	handler.ConflictError(c, "transition Published -> Draft is not allowed")
	return
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
func (h *ArticleHandler) hookUpdateSearchIndex(row *model.Article) {
	// TODO: implement update_search_index
}

// ── Validation rules ─────────────────────────────────────────────
func validateArticle(req *model.ArticleCreateRequest) []string {
	var errs []string
	if !((!( req.Status == model.ArticleStatusType_Published ) || (req.PublishedAt != nil))) {
		errs = append(errs, "Published article must have a published_at timestamp")
	}
	if !(req.ViewCount >= 0) {
		errs = append(errs, "Article view count must not be negative")
	}
	if !(req.LikesCount >= 0) {
		errs = append(errs, "Article likes count must not be negative")
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
		Language: m.Language,
		ViewCount: m.ViewCount,
		LikesCount: m.LikesCount,
		IsFeatured: m.IsFeatured,
		PublishedAt: m.PublishedAt,
		AuthorID: m.AuthorID,
		FeaturedDeckID: m.FeaturedDeckID,
	}
}
