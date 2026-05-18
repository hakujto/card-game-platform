package cardsproject.controller.cards;

import cardsproject.domain.cards.CardAbility;
import cardsproject.service.cards.CardAbilityService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/card_abilities")
public class CardAbilityController {

    private final CardAbilityService service;

    public CardAbilityController(CardAbilityService service) {
        this.service = service;
    }

    @GetMapping
    public List<CardAbility> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CardAbility> create(@Valid @RequestBody CardAbility entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardAbility> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardAbility> update(@PathVariable Long id, @Valid @RequestBody CardAbility entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CardAbility> patch(@PathVariable Long id, @Valid @RequestBody CardAbility entity) {
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

    @GetMapping("/{id}/usable")
    public ResponseEntity<Boolean> isUsableAt(@PathVariable Long id, @RequestParam String timing) {
        return ResponseEntity.ok(service.isUsableAt(id, timing));
    }

    @GetMapping("/{id}/describe")
    public ResponseEntity<String> describe(@PathVariable Long id) {
        return ResponseEntity.ok(service.describe(id));
    }
}
