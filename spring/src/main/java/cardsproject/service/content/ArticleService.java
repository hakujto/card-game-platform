package cardsproject.service.content;

import cardsproject.domain.content.Article;
import cardsproject.repository.content.ArticleRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.content.ArticleStatusType;

@Service
public class ArticleService {

    private final ArticleRepository repository;

    public ArticleService(ArticleRepository repository) {
        this.repository = repository;
    }

    public List<Article> findAll() {
        return repository.findAll();
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
