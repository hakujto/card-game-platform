package handler_content

import (

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	model "cards_project/internal/model/content"
	"cards_project/internal/handler"
)

type ArticleCommentHandler struct { db *gorm.DB }

func NewArticleCommentHandler(db *gorm.DB) *ArticleCommentHandler {
	return &ArticleCommentHandler{db: db}
}

func (h *ArticleCommentHandler) RegisterRoutes(app fiber.Router) {
	g := app.Group("/api/article_comments")
	g.Get("", h.List)
	g.Post("", h.Create)
	g.Get("/:id", h.Get)
	g.Delete("/:id", h.Delete)
	g.Post("/:id/api/comments/{id}/hide", h.Hide)
	g.Post("/:id/api/comments/{id}/unhide", h.Unhide)
	g.Get("/:id/api/comments/{id}/is-reply", h.IsReply)
}

func (h *ArticleCommentHandler) List(c *fiber.Ctx) error {
	skip, limit := handler.Paginate(c)
	var rows []model.ArticleComment
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		return handler.DbError(c, err)
	}
	out := make([]model.ArticleCommentResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	return c.JSON(out)
}

func (h *ArticleCommentHandler) Create(c *fiber.Ctx) error {
	var req model.ArticleCommentCreateRequest
	if err := c.BodyParser(&req); err != nil {
		return handler.ValidationError(c, err.Error())
	}
	row := model.ArticleComment{}
	row.Body = req.Body
	row.IsHidden = req.IsHidden
	row.ArticleID = req.ArticleID
	row.AuthorID = req.AuthorID
	row.ParentCommentID = req.ParentCommentID
	if err := h.db.Create(&row).Error; err != nil {
		if handler.IsUniqueViolation(err) { return handler.UnprocessableError(c, "Value must be unique") }
		return handler.DbError(c, err)
	}
	return c.Status(fiber.StatusCreated).JSON(row.ToResponse())
}

func (h *ArticleCommentHandler) Get(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleComment") }
		return handler.DbError(c, err)
	}
	return c.JSON(row.ToResponse())
}

func (h *ArticleCommentHandler) Delete(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	if err := h.db.Delete(&model.ArticleComment{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleComment") }
		return handler.DbError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleCommentHandler) Hide(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleComment") }
		return handler.DbError(c, err)
	}
	err := row.Hide()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleCommentHandler) Unhide(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleComment") }
		return handler.DbError(c, err)
	}
	err := row.Unhide()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.SendStatus(fiber.StatusNoContent)
}

func (h *ArticleCommentHandler) IsReply(c *fiber.Ctx) error {
	id, ok := handler.ParseID(c); if !ok { return nil }
	var row model.ArticleComment
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { return handler.NotFound(c, "ArticleComment") }
		return handler.DbError(c, err)
	}
	result, err := row.IsReply()
	if err != nil { return handler.DbError(c, err) }
	h.db.Save(&row)
	return c.JSON(fiber.Map{"result": result})
}
