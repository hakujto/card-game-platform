package cardsproject.controller.content;

import cardsproject.domain.content.ArticleTagAssignment;
import cardsproject.service.content.ArticleTagAssignmentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/article_tag_assignments")
public class ArticleTagAssignmentController {

    private final ArticleTagAssignmentService service;

    public ArticleTagAssignmentController(ArticleTagAssignmentService service) {
        this.service = service;
    }

    @GetMapping
    public List<ArticleTagAssignment> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<ArticleTagAssignment> create(@Valid @RequestBody ArticleTagAssignment entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ArticleTagAssignment> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ArticleTagAssignment> update(@PathVariable Long id, @Valid @RequestBody ArticleTagAssignment entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ArticleTagAssignment> patch(@PathVariable Long id, @Valid @RequestBody ArticleTagAssignment entity) {
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
