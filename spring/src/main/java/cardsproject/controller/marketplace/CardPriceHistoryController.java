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

    @GetMapping("/{id}")
    public ResponseEntity<CardPriceHistory> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }


    @GetMapping("/{id}/change")
    public ResponseEntity<java.math.BigDecimal> priceChangePercent(@PathVariable Long id, @RequestParam java.math.BigDecimal previousAvg) {
        try {
            return ResponseEntity.ok(service.priceChangePercent(id, previousAvg));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/spike")
    public ResponseEntity<Boolean> isPriceSpike(@PathVariable Long id, @RequestParam Integer thresholdPercent) {
        try {
            return ResponseEntity.ok(service.isPriceSpike(id, thresholdPercent));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
