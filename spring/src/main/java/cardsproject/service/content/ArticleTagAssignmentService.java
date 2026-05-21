package cardsproject.service.content;

import cardsproject.domain.content.ArticleTagAssignment;
import cardsproject.repository.content.ArticleTagAssignmentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ArticleTagAssignmentService {

    private final ArticleTagAssignmentRepository repository;

    public ArticleTagAssignmentService(ArticleTagAssignmentRepository repository) {
        this.repository = repository;
    }

    public List<ArticleTagAssignment> findAll() {
        return repository.findAll();
    }

    public Optional<ArticleTagAssignment> findById(Long id) {
        return repository.findById(id);
    }

    public ArticleTagAssignment save(ArticleTagAssignment entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(ArticleTagAssignment entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("articleId") && patch.get("articleId") != null) entity.setArticleId(Long.valueOf(patch.get("articleId").toString()));
        if (patch.containsKey("tagId") && patch.get("tagId") != null) entity.setTagId(Long.valueOf(patch.get("tagId").toString()));
    }
}
