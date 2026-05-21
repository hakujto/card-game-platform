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
    public List<ArticleTag> list(@RequestParam(required = false) String q) {
        return service.search(q);
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

    @PatchMapping("/{id}")
    public ResponseEntity<ArticleTag> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @PatchMapping("/{id}/rename")
    public ResponseEntity<Void> rename(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.rename(id, (String) body.get("new_name"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/article-count")
    public ResponseEntity<Integer> articleCount(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.articleCount(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
