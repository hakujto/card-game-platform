package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// ArticleCommentCreateRequest is the POST body.
type ArticleCommentCreateRequest struct {
	Body string `json:"body" binding:"required"`
	IsHidden bool `json:"is_hidden"`
	ArticleID uint `json:"article_id"`
	AuthorID uint `json:"author_id"`
	ParentCommentID *uint `json:"parent_comment_id"`
}

// ArticleCommentUpdateRequest is the PUT/PATCH body — all fields optional.
type ArticleCommentUpdateRequest struct {
	Body *string `json:"body"`
	IsHidden *bool `json:"is_hidden"`
	ArticleID *uint `json:"article_id"`
	AuthorID *uint `json:"author_id"`
	ParentCommentID *uint `json:"parent_comment_id"`
}

// ArticleCommentResponse is the JSON representation returned by the API.
type ArticleCommentResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Body string `json:"body"`
	IsHidden bool `json:"is_hidden"`
	ArticleID uint `json:"article_id"`
	AuthorID uint `json:"author_id"`
	ParentCommentID *uint `json:"parent_comment_id"`
}

type ArticleComment struct {
	gorm.Model
	Body string `gorm:"column:body;type:text;not null"`
	IsHidden bool `gorm:"column:is_hidden;default:false"`
	ArticleID uint `gorm:"column:article_id"`
	AuthorID uint `gorm:"column:author_id"`
	ParentCommentID *uint `gorm:"column:parent_comment_id"`
}

func (m *ArticleComment) ToResponse() ArticleCommentResponse {
	return ArticleCommentResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Body: m.Body,
		IsHidden: m.IsHidden,
		ArticleID: m.ArticleID,
		AuthorID: m.AuthorID,
		ParentCommentID: m.ParentCommentID,
	}
}

func (m *ArticleComment) ApplyUpdate(req ArticleCommentUpdateRequest) {
	if req.Body != nil { m.Body = *req.Body }
	if req.IsHidden != nil { m.IsHidden = *req.IsHidden }
	if req.ArticleID != nil { m.ArticleID = *req.ArticleID }
	if req.AuthorID != nil { m.AuthorID = *req.AuthorID }
	if req.ParentCommentID != nil { m.ParentCommentID = req.ParentCommentID }
}

func (m *ArticleComment) Hide()  error {
	return fmt.Errorf("Hide: not implemented")
}

func (m *ArticleComment) Unhide()  error {
	return fmt.Errorf("Unhide: not implemented")
}

func (m *ArticleComment) IsReply()  (bool, error) {
	return false, fmt.Errorf("IsReply: not implemented")
}
