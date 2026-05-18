package cardsproject.service.content;

import cardsproject.domain.content.ArticleTag;
import cardsproject.repository.content.ArticleTagRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ArticleTagService {

    private final ArticleTagRepository repository;

    public ArticleTagService(ArticleTagRepository repository) {
        this.repository = repository;
    }

    public List<ArticleTag> findAll() {
        return repository.findAll();
    }

    public Optional<ArticleTag> findById(Long id) {
        return repository.findById(id);
    }

    public ArticleTag save(ArticleTag entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void rename(Long id, String newName) {
        ArticleTag entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("ArticleTag not found: " + id));
        entity.rename(newName);
        repository.save(entity);
    }

    public Integer articleCount(Long id) {
        ArticleTag entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("ArticleTag not found: " + id));
        Integer result = entity.articleCount();
        repository.save(entity);
        return result;
    }
}
