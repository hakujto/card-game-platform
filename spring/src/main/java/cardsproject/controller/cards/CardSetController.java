package cardsproject.controller.cards;

import cardsproject.domain.cards.CardSet;
import cardsproject.service.cards.CardSetService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/card_sets")
public class CardSetController {

    private final CardSetService service;

    public CardSetController(CardSetService service) {
        this.service = service;
    }


    @GetMapping
    public List<CardSet> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<CardSet> create(@Valid @RequestBody CardSet entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardSet> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardSet> update(@PathVariable Long id, @Valid @RequestBody CardSet entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CardSet> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }


    @GetMapping("/{id}/standard-legal")
    public ResponseEntity<Boolean> isLegalInStandard(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isLegalInStandard(id));
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

    @GetMapping("/{id}/rarity-count")
    public ResponseEntity<Integer> cardCountByRarity(@PathVariable Long id, @RequestParam String rarity) {
        try {
            return ResponseEntity.ok(service.cardCountByRarity(id, rarity));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/rotate")
    public ResponseEntity<Void> rotateOut(@PathVariable Long id) {
        try {
            service.rotateOut(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
