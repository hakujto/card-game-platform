package cardsproject.controller.content;

import cardsproject.domain.content.ArticleTag;
import cardsproject.service.content.ArticleTagService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/article_tags")
public class ArticleTagController {

    private final ArticleTagService service;

    public ArticleTagController(ArticleTagService service) {
        this.service = service;
    }

    @GetMapping
    public List<ArticleTag> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<ArticleTag> create(@Valid @RequestBody ArticleTag entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ArticleTag> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ArticleTag> update(@PathVariable Long id, @Valid @RequestBody ArticleTag entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ArticleTag> patch(@PathVariable Long id, @Valid @RequestBody ArticleTag entity) {
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
