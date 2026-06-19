package cardsproject.controller.cards;

import cardsproject.domain.cards.Card;
import cardsproject.service.cards.CardService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/cards")
public class CardController {

    private final CardService service;

    public CardController(CardService service) {
        this.service = service;
    }


    @GetMapping
    public List<Card> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Card> create(@Valid @RequestBody Card entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Card not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Card entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Card not found"));
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Card not found")));
    }


    @PostMapping("/{id}/ban")
    public ResponseEntity<Void> ban(@PathVariable Long id) {
        try {
            service.ban(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/unban")
    public ResponseEntity<Void> unban(@PathVariable Long id) {
        try {
            service.unban(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/restrict")
    public ResponseEntity<Void> restrict(@PathVariable Long id) {
        try {
            service.restrict(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/unrestrict")
    public ResponseEntity<Void> unrestrict(@PathVariable Long id) {
        try {
            service.unrestrict(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/value")
    public ResponseEntity<java.math.BigDecimal> calculateValue(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.calculateValue(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/rarity-bonus")
    public ResponseEntity<java.math.BigDecimal> applyRarityBonus(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            return ResponseEntity.ok(service.applyRarityBonus(id, (Integer) body.get("multiplier")));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/legal")
    public ResponseEntity<Boolean> isLegalInFormat(@PathVariable Long id, @RequestParam String format) {
        try {
            return ResponseEntity.ok(service.isLegalInFormat(id, format));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
