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
    public List<Card> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Card> create(@Valid @RequestBody Card entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Card> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Card> update(@PathVariable Long id, @Valid @RequestBody Card entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Card> patch(@PathVariable Long id, @Valid @RequestBody Card entity) {
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

    @PostMapping("/{id}/ban")
    public ResponseEntity<Void> ban(@PathVariable Long id) {
        service.ban(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/unban")
    public ResponseEntity<Void> unban(@PathVariable Long id) {
        service.unban(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restrict")
    public ResponseEntity<Void> restrict(@PathVariable Long id) {
        service.restrict(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/unrestrict")
    public ResponseEntity<Void> unrestrict(@PathVariable Long id) {
        service.unrestrict(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/value")
    public ResponseEntity<java.math.BigDecimal> calculateValue(@PathVariable Long id) {
        return ResponseEntity.ok(service.calculateValue(id));
    }
}
