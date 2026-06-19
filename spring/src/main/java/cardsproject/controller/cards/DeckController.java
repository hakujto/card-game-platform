package cardsproject.controller.cards;

import cardsproject.domain.cards.Deck;
import cardsproject.service.cards.DeckService;
import jakarta.validation.Valid;
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
    public List<Deck> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Deck> create(@Valid @RequestBody Deck entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Deck not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Deck entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Deck not found"));
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Deck not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Deck not found"));
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/{id}/validate")
    public ResponseEntity<Boolean> validateSize(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.validateSize(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/cards")
    public ResponseEntity<Void> addCard(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.addCard(id, (Integer) body.get("card_id"), (Integer) body.get("quantity"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}/cards/{card_id}")
    public ResponseEntity<Void> removeCard(@PathVariable Long id, @PathVariable Long cardId) {
        try {
            service.removeCard(id, cardId);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/win-rate")
    public ResponseEntity<java.math.BigDecimal> winRate(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.winRate(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/clone")
    public ResponseEntity<Deck> clone(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.clone(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/publish")
    public ResponseEntity<Void> publish(@PathVariable Long id) {
        try {
            service.publish(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/unpublish")
    public ResponseEntity<Void> unpublish(@PathVariable Long id) {
        try {
            service.unpublish(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/certify")
    public ResponseEntity<Boolean> certifyTournamentLegal(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.certifyTournamentLegal(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
