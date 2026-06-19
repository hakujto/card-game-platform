package cardsproject.controller.content;

import cardsproject.domain.content.ArticleComment;
import cardsproject.service.content.ArticleCommentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/article_comments")
public class ArticleCommentController {

    private final ArticleCommentService service;

    public ArticleCommentController(ArticleCommentService service) {
        this.service = service;
    }


    @GetMapping
    public List<ArticleComment> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<ArticleComment> create(@Valid @RequestBody ArticleComment entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "ArticleComment not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "ArticleComment not found"));
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @PostMapping("/{id}/hide")
    public ResponseEntity<Void> hide(@PathVariable Long id) {
        try {
            service.hide(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/unhide")
    public ResponseEntity<Void> unhide(@PathVariable Long id) {
        try {
            service.unhide(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/is-reply")
    public ResponseEntity<Boolean> isReply(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isReply(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
