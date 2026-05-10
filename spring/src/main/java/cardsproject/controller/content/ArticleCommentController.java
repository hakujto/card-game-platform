package cardsproject.controller.content;

import cardsproject.domain.content.ArticleComment;
import cardsproject.service.content.ArticleCommentService;
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
    public ResponseEntity<ArticleComment> create(@RequestBody ArticleComment entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ArticleComment> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ArticleComment> update(@PathVariable Long id, @RequestBody ArticleComment entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ArticleComment> patch(@PathVariable Long id, @RequestBody ArticleComment entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
