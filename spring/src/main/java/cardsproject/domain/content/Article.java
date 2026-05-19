package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "articles")
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title = "";
    private String slug = "";
    private String body = "";
    private String excerpt;
    private String coverImageUrl;
    @Enumerated(EnumType.STRING)
    private ArticleStatusType status;
    @Enumerated(EnumType.STRING)
    private ArticleArticleTypeType articleType;
    @Enumerated(EnumType.STRING)
    private ArticleLanguageType language;
    private Integer viewCount = 0;
    private Integer likesCount = 0;
    private Boolean isFeatured = false;
    private LocalDateTime publishedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Column(name = "author_id")
    private Long authorId;
    @Column(name = "featured_deck_id")
    private Long featuredDeckId;

    // M2M: tags managed via join table

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public String getExcerpt() { return excerpt; }
    public void setExcerpt(String excerpt) { this.excerpt = excerpt; }
    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }
    public ArticleStatusType getStatus() { return status; }
    public void setStatus(ArticleStatusType status) { this.status = status; }
    public ArticleArticleTypeType getArticleType() { return articleType; }
    public void setArticleType(ArticleArticleTypeType articleType) { this.articleType = articleType; }
    public ArticleLanguageType getLanguage() { return language; }
    public void setLanguage(ArticleLanguageType language) { this.language = language; }
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
    public Integer getLikesCount() { return likesCount; }
    public void setLikesCount(Integer likesCount) { this.likesCount = likesCount; }
    public Boolean getIsFeatured() { return isFeatured; }
    public void setIsFeatured(Boolean isFeatured) { this.isFeatured = isFeatured; }
    public LocalDateTime getPublishedAt() { return publishedAt; }
    public void setPublishedAt(LocalDateTime publishedAt) { this.publishedAt = publishedAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public Long getAuthorId() { return authorId; }
    public void setAuthorId(Long authorId) { this.authorId = authorId; }
    public Long getFeaturedDeckId() { return featuredDeckId; }
    public void setFeaturedDeckId(Long featuredDeckId) { this.featuredDeckId = featuredDeckId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void publish() {
        // TODO: implement publish
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void archive() {
        // TODO: implement archive
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void incrementView() {
        // TODO: implement incrementView
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void like() {
        // TODO: implement like
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void unlike() {
        // TODO: implement unlike
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer readingTimeMinutes() {
        // TODO: implement readingTimeMinutes
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Article view count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isViewCountNotNegativeValid() {
        return (getViewCount() == null || getViewCount() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Article likes count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isLikesCountNotNegativeValid() {
        return (getLikesCount() == null || getLikesCount() >= 0);
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<ArticleStatusType, java.util.List<ArticleStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(ArticleStatusType.DRAFT, java.util.List.of(ArticleStatusType.PUBLISHED)),
        java.util.Map.entry(ArticleStatusType.PUBLISHED, java.util.List.of(ArticleStatusType.ARCHIVED)),
        java.util.Map.entry(ArticleStatusType.ARCHIVED, java.util.List.of(ArticleStatusType.DRAFT))
        );

    public void assertTransition(ArticleStatusType to) {
        java.util.List<ArticleStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
