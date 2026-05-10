package cardsproject.controller.cards;

import cardsproject.domain.cards.CardRuling;
import cardsproject.service.cards.CardRulingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/card_rulings")
public class CardRulingController {

    private final CardRulingService service;

    public CardRulingController(CardRulingService service) {
        this.service = service;
    }

    @GetMapping
    public List<CardRuling> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CardRuling> create(@RequestBody CardRuling entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardRuling> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardRuling> update(@PathVariable Long id, @RequestBody CardRuling entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CardRuling> patch(@PathVariable Long id, @RequestBody CardRuling entity) {
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
