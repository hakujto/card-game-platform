package cardsproject.domain.content;

import jakarta.persistence.*;

@Entity
@Table(name = "article_tag_assignments")
public class ArticleTagAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    // @ManyToOne -> Article, onDelete=CASCADE, relatedName=tag_assignments
    @Column(name = "article_id")
    private Long articleId;
    // @ManyToOne -> ArticleTag, onDelete=CASCADE, relatedName=article_assignments
    @Column(name = "tag_id")
    private Long tagId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getArticleId() { return articleId; }
    public void setArticleId(Long articleId) { this.articleId = articleId; }
    public Long getTagId() { return tagId; }
    public void setTagId(Long tagId) { this.tagId = tagId; }
}
