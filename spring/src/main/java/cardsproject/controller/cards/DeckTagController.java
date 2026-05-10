package cardsproject.controller.cards;

import cardsproject.domain.cards.DeckTag;
import cardsproject.service.cards.DeckTagService;
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
    public List<DeckTag> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DeckTag> create(@RequestBody DeckTag entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckTag> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DeckTag> update(@PathVariable Long id, @RequestBody DeckTag entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DeckTag> patch(@PathVariable Long id, @RequestBody DeckTag entity) {
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
