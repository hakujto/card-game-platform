package cardsproject.controller.cards;

import cardsproject.domain.cards.CardSet;
import cardsproject.service.cards.CardSetService;
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
    public List<CardSet> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CardSet> create(@RequestBody CardSet entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardSet> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardSet> update(@PathVariable Long id, @RequestBody CardSet entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CardSet> patch(@PathVariable Long id, @RequestBody CardSet entity) {
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
