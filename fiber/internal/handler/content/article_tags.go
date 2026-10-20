package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleTagHandler struct { db *gorm.DB }

func NewArticleTagHandler(db *gorm.DB) *ArticleTagHandler {
	return &ArticleTagHandler{db: db}
}

func (h *ArticleTagHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/article_tags")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Patch("/:id", h.Patch)
	g.Delete("/:id", h.Delete)
	g.Patch("/:id/rename", h.Rename)
	g.Get("/:id/article-count", h.ArticleCount)
}

func (h *ArticleTagHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleTag
	q := c.Query("q")
	db := h.db
	if q != "" {
		db = db.Or("name LIKE ?", "%"+q+"%")
	}
	if err := db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.ArticleTagResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *ArticleTagHandler) Create(c *fiber.Ctx) error {
	var req model.ArticleTagCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.ArticleTag{}
	row.Name = req.Name
	row.Slug = req.Slug
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *ArticleTagHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTag") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleTagHandler) Patch(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTag") }
		return handler.DbError(c, err)
	}
	var req model.ArticleTagUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleTagHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.ArticleTag{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTag") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleTagHandler) Rename(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTag") }
		return handler.DbError(c, err)
	}
	var body map[string]interface{}
	_ = c.BodyParser(&body)
	newName := func() string {
		v, ok := body["new_name"]; if !ok { return "" }
		s, ok := v.(string); if !ok { return "" }
		return s
	}()
	err := row.Rename(newName)
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleTagHandler) ArticleCount(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleTag
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTag") }
		return handler.DbError(c, err)
	}
	result, err := row.ArticleCount()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}
