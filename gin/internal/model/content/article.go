package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type ArticleStatusType string
const (
	ArticleStatusType_Draft ArticleStatusType = "Draft"
	ArticleStatusType_Published ArticleStatusType = "Published"
	ArticleStatusType_Archived ArticleStatusType = "Archived"
)

type ArticleArticleTypeType string
const (
	ArticleArticleTypeType_Guide ArticleArticleTypeType = "Guide"
	ArticleArticleTypeType_Tierlist ArticleArticleTypeType = "Tierlist"
	ArticleArticleTypeType_Matchup ArticleArticleTypeType = "Matchup"
	ArticleArticleTypeType_News ArticleArticleTypeType = "News"
	ArticleArticleTypeType_Spotlight ArticleArticleTypeType = "Spotlight"
	ArticleArticleTypeType_Decklist ArticleArticleTypeType = "Decklist"
)

// ArticleCreateRequest is the POST body.
type ArticleCreateRequest struct {
	Title string `json:"title" binding:"required"`
	Slug string `json:"slug" binding:"required"`
	Body string `json:"body" binding:"required"`
	Excerpt *string `json:"excerpt"`
	CoverImageUrl *string `json:"cover_image_url"`
	Status ArticleStatusType `json:"status" binding:"required"`
	ArticleType ArticleArticleTypeType `json:"article_type" binding:"required"`
	ViewCount int `json:"view_count"`
	PublishedAt *string `json:"published_at"`
	AuthorID uint `json:"author_id"`
	FeaturedDeckID *uint `json:"featured_deck_id"`
}

// ArticleUpdateRequest is the PUT/PATCH body — all fields optional.
type ArticleUpdateRequest struct {
	Title *string `json:"title"`
	Slug *string `json:"slug"`
	Body *string `json:"body"`
	Excerpt *string `json:"excerpt"`
	CoverImageUrl *string `json:"cover_image_url"`
	Status *ArticleStatusType `json:"status"`
	ArticleType *ArticleArticleTypeType `json:"article_type"`
	ViewCount *int `json:"view_count"`
	PublishedAt *string `json:"published_at"`
	AuthorID *uint `json:"author_id"`
	FeaturedDeckID *uint `json:"featured_deck_id"`
}

// ArticleResponse is the JSON representation returned by the API.
type ArticleResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Title string `json:"title"`
	Slug string `json:"slug"`
	Body string `json:"body"`
	Excerpt *string `json:"excerpt"`
	CoverImageUrl *string `json:"cover_image_url"`
	Status ArticleStatusType `json:"status"`
	ArticleType ArticleArticleTypeType `json:"article_type"`
	ViewCount int `json:"view_count"`
	PublishedAt *string `json:"published_at"`
	AuthorID uint `json:"author_id"`
	FeaturedDeckID *uint `json:"featured_deck_id"`
}

type Article struct {
	gorm.Model
	Title string `gorm:"column:title;not null"`
	Slug string `gorm:"column:slug;not null"`
	Body string `gorm:"column:body;type:text;not null"`
	Excerpt *string `gorm:"column:excerpt;type:text"`
	CoverImageUrl *string `gorm:"column:cover_image_url"`
	Status ArticleStatusType `gorm:"column:status;not null;default:'Draft'"`
	ArticleType ArticleArticleTypeType `gorm:"column:article_type;not null;default:'Guide'"`
	ViewCount int `gorm:"column:view_count;not null;default:0"`
	PublishedAt *string `gorm:"column:published_at"`
	AuthorID uint `gorm:"column:author_id"`
	FeaturedDeckID *uint `gorm:"column:featured_deck_id"`
	TagsIDs []uint `gorm:"serializer:json;column:tags_ids"`
}

func (m *Article) ToResponse() ArticleResponse {
	return ArticleResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
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

func (m *Article) ApplyUpdate(req ArticleUpdateRequest) {
	if req.Title != nil { m.Title = *req.Title }
	if req.Slug != nil { m.Slug = *req.Slug }
	if req.Body != nil { m.Body = *req.Body }
	if req.Excerpt != nil { m.Excerpt = req.Excerpt }
	if req.CoverImageUrl != nil { m.CoverImageUrl = req.CoverImageUrl }
	if req.Status != nil { m.Status = *req.Status }
	if req.ArticleType != nil { m.ArticleType = *req.ArticleType }
	if req.ViewCount != nil { m.ViewCount = *req.ViewCount }
	if req.PublishedAt != nil { m.PublishedAt = req.PublishedAt }
	if req.AuthorID != nil { m.AuthorID = *req.AuthorID }
	if req.FeaturedDeckID != nil { m.FeaturedDeckID = req.FeaturedDeckID }
}

func (m *Article) Publish()  error {
	return fmt.Errorf("Publish: not implemented")
}

func (m *Article) Archive()  error {
	return fmt.Errorf("Archive: not implemented")
}

func (m *Article) IncrementView()  error {
	return fmt.Errorf("IncrementView: not implemented")
}

func (m *Article) ReadingTimeMinutes()  (int, error) {
	return 0, fmt.Errorf("ReadingTimeMinutes: not implemented")
}
