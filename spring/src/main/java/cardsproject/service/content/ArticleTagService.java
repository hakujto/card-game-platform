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
}
