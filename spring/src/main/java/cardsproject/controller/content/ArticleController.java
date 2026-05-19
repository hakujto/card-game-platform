package cardsproject.controller.content;

import cardsproject.domain.content.Article;
import cardsproject.service.content.ArticleService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/articles")
public class ArticleController {

    private final ArticleService service;

    public ArticleController(ArticleService service) {
        this.service = service;
    }

    @GetMapping
    public List<Article> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Article> create(@Valid @RequestBody Article entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Article> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Article> update(@PathVariable Long id, @Valid @RequestBody Article entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Article> patch(@PathVariable Long id, @Valid @RequestBody Article entity) {
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

    @PostMapping("/{id}/publish")
    public ResponseEntity<Void> publish(@PathVariable Long id) {
        service.publish(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/archive")
    public ResponseEntity<Void> archive(@PathVariable Long id) {
        service.archive(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/view")
    public ResponseEntity<Void> incrementView(@PathVariable Long id) {
        service.incrementView(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<Void> like(@PathVariable Long id) {
        service.like(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}/like")
    public ResponseEntity<Void> unlike(@PathVariable Long id) {
        service.unlike(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/reading-time")
    public ResponseEntity<Integer> readingTimeMinutes(@PathVariable Long id) {
        return ResponseEntity.ok(service.readingTimeMinutes(id));
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_EDITOR')")
    @PatchMapping("/{id}/transitions/draft-to-published")
    public ResponseEntity<?> transitionDraftToPublished(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionDraftToPublished(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_EDITOR')")
    @PatchMapping("/{id}/transitions/published-to-archived")
    public ResponseEntity<?> transitionPublishedToArchived(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPublishedToArchived(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/archived-to-draft")
    public ResponseEntity<?> transitionArchivedToDraft(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionArchivedToDraft(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/transitions/published-to-draft")
    public ResponseEntity<?> transitionPublishedToDraft(@PathVariable Long id) {
        try {
            service.transitionPublishedToDraft(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }
}
