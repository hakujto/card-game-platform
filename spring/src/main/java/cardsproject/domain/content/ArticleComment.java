package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "article_comments")
public class ArticleComment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String body = "";
    private Boolean isHidden = false;
    private LocalDateTime createdAt;

    // @ManyToOne -> Article, onDelete=CASCADE, relatedName=comments
    @Column(name = "article_id")
    private Long articleId;
    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=article_comments, via=players
    @Column(name = "author_id")
    private Long authorId;
    // @ManyToOne -> ArticleComment, onDelete=SET_NULL, relatedName=replies
    @Column(name = "parent_comment_id")
    private Long parentCommentId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public Boolean getIsHidden() { return isHidden; }
    public void setIsHidden(Boolean isHidden) { this.isHidden = isHidden; }
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Long getArticleId() { return articleId; }
    public void setArticleId(Long articleId) { this.articleId = articleId; }
    public Long getAuthorId() { return authorId; }
    public void setAuthorId(Long authorId) { this.authorId = authorId; }
    public Long getParentCommentId() { return parentCommentId; }
    public void setParentCommentId(Long parentCommentId) { this.parentCommentId = parentCommentId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void hide() {
        // TODO: implement hide
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void unhide() {
        // TODO: implement unhide
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isReply() {
        // TODO: implement isReply
        return null;
    }
}
