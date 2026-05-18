package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.CardPriceHistory;
import cardsproject.service.marketplace.CardPriceHistoryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/card_price_histories")
public class CardPriceHistoryController {

    private final CardPriceHistoryService service;

    public CardPriceHistoryController(CardPriceHistoryService service) {
        this.service = service;
    }

    @GetMapping
    public List<CardPriceHistory> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CardPriceHistory> create(@Valid @RequestBody CardPriceHistory entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardPriceHistory> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardPriceHistory> update(@PathVariable Long id, @Valid @RequestBody CardPriceHistory entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CardPriceHistory> patch(@PathVariable Long id, @Valid @RequestBody CardPriceHistory entity) {
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

    @GetMapping("/{id}/change")
    public ResponseEntity<java.math.BigDecimal> priceChangePercent(@PathVariable Long id, @RequestParam java.math.BigDecimal previousAvg) {
        return ResponseEntity.ok(service.priceChangePercent(id, previousAvg));
    }

    @GetMapping("/{id}/spike")
    public ResponseEntity<Boolean> isPriceSpike(@PathVariable Long id, @RequestParam Integer thresholdPercent) {
        return ResponseEntity.ok(service.isPriceSpike(id, thresholdPercent));
    }
}
