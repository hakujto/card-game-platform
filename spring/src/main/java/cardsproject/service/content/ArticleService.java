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
}
