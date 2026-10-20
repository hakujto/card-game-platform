package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleHandler struct { db *gorm.DB }

func NewArticleHandler(db *gorm.DB) *ArticleHandler {
	return &ArticleHandler{db: db}
}

func (h *ArticleHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/articles")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Put("/:id", h.Update)
	g.Patch("/:id", h.Patch)
	g.Post("/:id/publish", h.Publish)
	g.Post("/:id/archive", h.Archive)
	g.Post("/:id/view", h.IncrementView)
	g.Post("/:id/like", h.Like)
	g.Delete("/:id/like", h.Unlike)
	g.Get("/:id/reading-time", h.ReadingTimeMinutes)
	g.Patch("/:id/transitions/draft-to-published", h.TransitionDraftToPublished)
	g.Patch("/:id/transitions/published-to-archived", h.TransitionPublishedToArchived)
	g.Patch("/:id/transitions/archived-to-draft", h.TransitionArchivedToDraft)
	g.Patch("/:id/transitions/published-to-draft", h.TransitionPublishedToDraft)
}

func (h *ArticleHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.Article
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("title LIKE ?", "%"+q+"%")
		db = db.Or("excerpt LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.ArticleResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *ArticleHandler) Create(c *fiber.Ctx) error {
	var req model.ArticleCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	if msgs := validateArticle(&req); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
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
	row.TotalViewsAlltime = req.TotalViewsAlltime
	row.IsFeatured = req.IsFeatured
	row.PublishedAt = req.PublishedAt
	row.AuthorID = req.AuthorID
	row.FeaturedDeckID = req.FeaturedDeckID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *ArticleHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleHandler) Update(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	var req model.ArticleUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	createReq := toCreateRequestArticle(&row)
	if msgs := validateArticle(&createReq); len(msgs) > 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"errors": msgs})
	}
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleHandler) Patch(c *fiber.Ctx) error { return h.Update(c) }

func (h *ArticleHandler) Publish(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesPublish := []string{"editor", "admin"}
	roleOkPublish := false
	for _, r := range allowedRolesPublish { if r == userRole { roleOkPublish = true; break } }
	if !roleOkPublish { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for publish"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	err := row.Publish()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleHandler) Archive(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesArchive := []string{"editor", "admin"}
	roleOkArchive := false
	for _, r := range allowedRolesArchive { if r == userRole { roleOkArchive = true; break } }
	if !roleOkArchive { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for archive"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	err := row.Archive()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleHandler) Replace(c *fiber.Ctx) error {
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesReplace := []string{"editor", "admin"}
	roleOkReplace := false
	for _, r := range allowedRolesReplace { if r == userRole { roleOkReplace = true; break } }
	if !roleOkReplace { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for replace"}) }
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	data := func() string {
		v, ok := body["data"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	result, err := row.Replace(data)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *ArticleHandler) IncrementView(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	err := row.IncrementView()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleHandler) Like(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	err := row.Like()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleHandler) Unlike(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	err := row.Unlike()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleHandler) ReadingTimeMinutes(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	result, err := row.ReadingTimeMinutes()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}

func (h *ArticleHandler) TransitionDraftToPublished(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionDraftToPublished := []string{"Editor", "Admin"}
	roleOkTransitionDraftToPublished := false
	for _, r := range allowedRolesTransitionDraftToPublished { if r == userRole { roleOkTransitionDraftToPublished = true; break } }
	if !roleOkTransitionDraftToPublished { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Draft -> Published"}) }
	if err := row.AssertTransition("Published"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	if row.Title == "" {
		return handler.UnprocessableError(c, "title is required for this transition")
	}
	if row.Body == "" {
		return handler.UnprocessableError(c, "body is required for this transition")
	}
	row.Status = model.ArticleStatusType_Published
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Publish() // @after
	return c.JSON(row.ToResponse())
}

func (h *ArticleHandler) TransitionPublishedToArchived(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionPublishedToArchived := []string{"Editor", "Admin"}
	roleOkTransitionPublishedToArchived := false
	for _, r := range allowedRolesTransitionPublishedToArchived { if r == userRole { roleOkTransitionPublishedToArchived = true; break } }
	if !roleOkTransitionPublishedToArchived { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Published -> Archived"}) }
	if err := row.AssertTransition("Archived"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.ArticleStatusType_Archived
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	_ = row.Archive() // @after
	return c.JSON(row.ToResponse())
}

func (h *ArticleHandler) TransitionArchivedToDraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	userRole, _ := c.Locals("user_role").(string)
	allowedRolesTransitionArchivedToDraft := []string{"Admin"}
	roleOkTransitionArchivedToDraft := false
	for _, r := range allowedRolesTransitionArchivedToDraft { if r == userRole { roleOkTransitionArchivedToDraft = true; break } }
	if !roleOkTransitionArchivedToDraft { return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Insufficient role for transition Archived -> Draft"}) }
	if err := row.AssertTransition("Draft"); err != nil {
		return handler.ConflictError(c, err.Error())
	}
	row.Status = model.ArticleStatusType_Draft
	if err := h.db.Save(&row).Error; err != nil {
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleHandler) TransitionPublishedToDraft(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.Article
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "Article") }
		return handler.DbError(c, err)
	}
	return handler.ConflictError(c, "transition Published -> Draft is not allowed")
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
		TotalViewsAlltime: m.TotalViewsAlltime,
		IsFeatured: m.IsFeatured,
		PublishedAt: m.PublishedAt,
		AuthorID: m.AuthorID,
		FeaturedDeckID: m.FeaturedDeckID,
	}
}
