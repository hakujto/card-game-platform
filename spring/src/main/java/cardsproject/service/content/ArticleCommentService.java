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

    public void applyPatch(ArticleComment entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("body") && patch.get("body") != null) entity.setBody(patch.get("body").toString());
        if (patch.containsKey("isHidden") && patch.get("isHidden") != null) entity.setIsHidden(Boolean.valueOf(patch.get("isHidden").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("articleId") && patch.get("articleId") != null) entity.setArticleId(Long.valueOf(patch.get("articleId").toString()));
        if (patch.containsKey("authorId") && patch.get("authorId") != null) entity.setAuthorId(Long.valueOf(patch.get("authorId").toString()));
        if (patch.containsKey("parentCommentId") && patch.get("parentCommentId") != null) entity.setParentCommentId(Long.valueOf(patch.get("parentCommentId").toString()));
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

    public Boolean isReply(Long id) {
        ArticleComment entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("ArticleComment not found: " + id));
        Boolean result = entity.isReply();
        repository.save(entity);
        return result;
    }
}
