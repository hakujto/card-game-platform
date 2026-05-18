package model_content

import (
	"time"

	"gorm.io/gorm"
)

// ArticleTagAssignmentCreateRequest is the POST body.
type ArticleTagAssignmentCreateRequest struct {
	ArticleID uint `json:"article_id"`
	TagID uint `json:"tag_id"`
}

// ArticleTagAssignmentUpdateRequest is the PUT/PATCH body — all fields optional.
type ArticleTagAssignmentUpdateRequest struct {
	ArticleID *uint `json:"article_id"`
	TagID *uint `json:"tag_id"`
}

// ArticleTagAssignmentResponse is the JSON representation returned by the API.
type ArticleTagAssignmentResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	ArticleID uint `json:"article_id"`
	TagID uint `json:"tag_id"`
}

type ArticleTagAssignment struct {
	gorm.Model
	ArticleID uint `gorm:"column:article_id"`
	TagID uint `gorm:"column:tag_id"`
}

func (m *ArticleTagAssignment) ToResponse() ArticleTagAssignmentResponse {
	return ArticleTagAssignmentResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		ArticleID: m.ArticleID,
		TagID: m.TagID,
	}
}

func (m *ArticleTagAssignment) ApplyUpdate(req ArticleTagAssignmentUpdateRequest) {
	if req.ArticleID != nil { m.ArticleID = *req.ArticleID }
	if req.TagID != nil { m.TagID = *req.TagID }
}
