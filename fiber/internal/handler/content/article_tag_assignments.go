package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleTagAssignmentHandler struct { db *gorm.DB }

func NewArticleTagAssignmentHandler(db *gorm.DB) *ArticleTagAssignmentHandler {
	return &ArticleTagAssignmentHandler{db: db}
}

func (h *ArticleTagAssignmentHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/article_tag_assignments")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
}

func (h *ArticleTagAssignmentHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleTagAssignment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.ArticleTagAssignmentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *ArticleTagAssignmentHandler) Create(c *fiber.Ctx) error {
	var req model.ArticleTagAssignmentCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.ArticleTagAssignment{}
	row.ArticleID = req.ArticleID
	row.TagID = req.TagID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *ArticleTagAssignmentHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleTagAssignment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTagAssignment") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleTagAssignmentHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.ArticleTagAssignment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleTagAssignment") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}
