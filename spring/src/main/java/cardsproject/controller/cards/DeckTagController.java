package cardsproject.controller.cards;

import cardsproject.domain.cards.DeckTag;
import cardsproject.service.cards.DeckTagService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/deck_tags")
public class DeckTagController {

    private final DeckTagService service;

    public DeckTagController(DeckTagService service) {
        this.service = service;
    }


    @GetMapping
    public List<DeckTag> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<DeckTag> create(@Valid @RequestBody DeckTag entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckTag> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DeckTag> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
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

    @PostMapping("/{id}/merge")
    public ResponseEntity<Void> mergeInto(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.mergeInto(id, (Integer) body.get("target_tag_id"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
