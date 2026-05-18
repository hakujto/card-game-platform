package cardsproject.controller.cards;

import cardsproject.domain.cards.DeckCard;
import cardsproject.service.cards.DeckCardService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/deck_cards")
public class DeckCardController {

    private final DeckCardService service;

    public DeckCardController(DeckCardService service) {
        this.service = service;
    }

    @GetMapping
    public List<DeckCard> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DeckCard> create(@Valid @RequestBody DeckCard entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckCard> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DeckCard> update(@PathVariable Long id, @Valid @RequestBody DeckCard entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DeckCard> patch(@PathVariable Long id, @Valid @RequestBody DeckCard entity) {
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

    @PatchMapping("/{id}/increment")
    public ResponseEntity<Void> increment(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.increment(id, (Integer) body.get("amount"));
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/decrement")
    public ResponseEntity<Void> decrement(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.decrement(id, (Integer) body.get("amount"));
        return ResponseEntity.noContent().build();
    }
}
