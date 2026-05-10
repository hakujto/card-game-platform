package cardsproject.service.content;

import cardsproject.domain.content.Article;
import cardsproject.repository.content.ArticleRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
