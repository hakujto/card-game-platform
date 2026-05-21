package cardsproject.service.content;

import cardsproject.domain.content.Article;
import cardsproject.repository.content.ArticleRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.content.ArticleStatusType;
import cardsproject.domain.content.ArticleArticleTypeType;
import cardsproject.domain.content.ArticleLanguageType;

@Service
public class ArticleService {

    private final ArticleRepository repository;

    public ArticleService(ArticleRepository repository) {
        this.repository = repository;
    }

    public List<Article> findAll() {
        return repository.findAll();
    }

    public List<Article> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getTitle() != null && e.getTitle().toLowerCase().contains(q.toLowerCase())) || (e.getExcerpt() != null && e.getExcerpt().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Article> findById(Long id) {
        return repository.findById(id);
    }

    public Article save(Article entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Article entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("title") && patch.get("title") != null) entity.setTitle(patch.get("title").toString());
        if (patch.containsKey("slug") && patch.get("slug") != null) entity.setSlug(patch.get("slug").toString());
        if (patch.containsKey("body") && patch.get("body") != null) entity.setBody(patch.get("body").toString());
        if (patch.containsKey("excerpt") && patch.get("excerpt") != null) entity.setExcerpt(patch.get("excerpt").toString());
        if (patch.containsKey("coverImageUrl") && patch.get("coverImageUrl") != null) entity.setCoverImageUrl(patch.get("coverImageUrl").toString());
        if (patch.containsKey("status")) entity.setStatus(ArticleStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("articleType")) entity.setArticleType(ArticleArticleTypeType.valueOf(patch.get("articleType").toString()));
        if (patch.containsKey("language")) entity.setLanguage(ArticleLanguageType.valueOf(patch.get("language").toString()));
        if (patch.containsKey("viewCount") && patch.get("viewCount") != null) entity.setViewCount(Integer.valueOf(patch.get("viewCount").toString()));
        if (patch.containsKey("likesCount") && patch.get("likesCount") != null) entity.setLikesCount(Integer.valueOf(patch.get("likesCount").toString()));
        if (patch.containsKey("isFeatured") && patch.get("isFeatured") != null) entity.setIsFeatured(Boolean.valueOf(patch.get("isFeatured").toString()));
        if (patch.containsKey("publishedAt") && patch.get("publishedAt") != null) entity.setPublishedAt(java.time.LocalDateTime.parse(patch.get("publishedAt").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("updatedAt") && patch.get("updatedAt") != null) entity.setUpdatedAt(java.time.LocalDateTime.parse(patch.get("updatedAt").toString()));
        if (patch.containsKey("authorId") && patch.get("authorId") != null) entity.setAuthorId(Long.valueOf(patch.get("authorId").toString()));
        if (patch.containsKey("featuredDeckId") && patch.get("featuredDeckId") != null) entity.setFeaturedDeckId(Long.valueOf(patch.get("featuredDeckId").toString()));
    }
    private void validate(Article entity) {
        if (ArticleStatusType.PUBLISHED.equals(entity.getStatus()) && entity.getPublishedAt() == null) throw new IllegalStateException("Published article must have a published_at timestamp");
    }

    public void publish(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.publish();
        repository.save(entity);
    }

    public void archive(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.archive();
        repository.save(entity);
    }

    public void incrementView(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.incrementView();
        repository.save(entity);
    }

    public void like(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.like();
        repository.save(entity);
    }

    public void unlike(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.unlike();
        repository.save(entity);
    }

    public Integer readingTimeMinutes(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        Integer result = entity.readingTimeMinutes();
        repository.save(entity);
        return result;
    }

    public Article transitionDraftToPublished(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.assertTransition(ArticleStatusType.PUBLISHED);
        if (entity.getTitle() == null) {
            throw new IllegalArgumentException("title is required for Draft -> Published");
        }
        if (entity.getBody() == null) {
            throw new IllegalArgumentException("body is required for Draft -> Published");
        }
        entity.setStatus(ArticleStatusType.PUBLISHED);
        entity.publish(); // @after
        return repository.save(entity);
    }

    public Article transitionPublishedToArchived(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.assertTransition(ArticleStatusType.ARCHIVED);
        entity.setStatus(ArticleStatusType.ARCHIVED);
        entity.archive(); // @after
        return repository.save(entity);
    }

    public Article transitionArchivedToDraft(Long id) {
        Article entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found: " + id));
        entity.assertTransition(ArticleStatusType.DRAFT);
        entity.setStatus(ArticleStatusType.DRAFT);
        return repository.save(entity);
    }

    public void transitionPublishedToDraft(Long id) {
        throw new IllegalStateException("Transition Published -> Draft is not allowed");
    }
}
