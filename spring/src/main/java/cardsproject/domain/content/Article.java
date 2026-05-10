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
    private Integer viewCount = 0;
    private LocalDateTime publishedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Column(name = "author_id")
    private Long authorId;
    @Column(name = "featured_deck_id")
    private Long featuredDeckId;
    @Column(name = "comments_id")
    private Long commentsId;

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
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
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
    public Long getCommentsId() { return commentsId; }
    public void setCommentsId(Long commentsId) { this.commentsId = commentsId; }
}
