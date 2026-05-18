package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

// ArticleTagCreateRequest is the POST body.
type ArticleTagCreateRequest struct {
	Name string `json:"name" binding:"required"`
	Slug string `json:"slug" binding:"required"`
}

// ArticleTagUpdateRequest is the PUT/PATCH body — all fields optional.
type ArticleTagUpdateRequest struct {
	Name *string `json:"name"`
	Slug *string `json:"slug"`
}

// ArticleTagResponse is the JSON representation returned by the API.
type ArticleTagResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	Slug string `json:"slug"`
}

type ArticleTag struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	Slug string `gorm:"column:slug;not null"`
}

func (m *ArticleTag) ToResponse() ArticleTagResponse {
	return ArticleTagResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		Slug: m.Slug,
	}
}

func (m *ArticleTag) ApplyUpdate(req ArticleTagUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.Slug != nil { m.Slug = *req.Slug }
}

func (m *ArticleTag) Rename(newName string)  error {
	return fmt.Errorf("Rename: not implemented")
}

func (m *ArticleTag) ArticleCount()  (int, error) {
	return 0, fmt.Errorf("ArticleCount: not implemented")
}
