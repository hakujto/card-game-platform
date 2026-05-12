package cardsproject.controller.cards;

import cardsproject.domain.cards.Deck;
import cardsproject.service.cards.DeckService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/decks")
public class DeckController {

    private final DeckService service;

    public DeckController(DeckService service) {
        this.service = service;
    }

    @GetMapping
    public List<Deck> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Deck> create(@RequestBody Deck entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Deck> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Deck> update(@PathVariable Long id, @RequestBody Deck entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Deck> patch(@PathVariable Long id, @RequestBody Deck entity) {
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

    @GetMapping("/{id}/validate")
    public ResponseEntity<Boolean> validateSize(@PathVariable Long id) {
        return ResponseEntity.ok(service.validateSize(id));
    }

    @PostMapping("/{id}/clone")
    public ResponseEntity<Deck> clone(@PathVariable Long id) {
        return ResponseEntity.ok(service.clone(id));
    }

    @PostMapping("/{id}/publish")
    public ResponseEntity<Void> publish(@PathVariable Long id) {
        service.publish(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/unpublish")
    public ResponseEntity<Void> unpublish(@PathVariable Long id) {
        service.unpublish(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/certify")
    public ResponseEntity<Boolean> certifyTournamentLegal(@PathVariable Long id) {
        return ResponseEntity.ok(service.certifyTournamentLegal(id));
    }
}
