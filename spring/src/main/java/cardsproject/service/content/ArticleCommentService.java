package cardsproject.service.content;

import cardsproject.domain.content.ArticleComment;
import cardsproject.repository.content.ArticleCommentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ArticleCommentService {

    private final ArticleCommentRepository repository;

    public ArticleCommentService(ArticleCommentRepository repository) {
        this.repository = repository;
    }

    public List<ArticleComment> findAll() {
        return repository.findAll();
    }

    public Optional<ArticleComment> findById(Long id) {
        return repository.findById(id);
    }

    public ArticleComment save(ArticleComment entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void hide(Long id) {
        ArticleComment entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("ArticleComment not found: " + id));
        entity.hide();
        repository.save(entity);
    }

    public void unhide(Long id) {
        ArticleComment entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("ArticleComment not found: " + id));
        entity.unhide();
        repository.save(entity);
    }
}
