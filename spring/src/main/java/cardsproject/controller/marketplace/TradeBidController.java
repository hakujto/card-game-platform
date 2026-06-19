package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.TradeBid;
import cardsproject.service.marketplace.TradeBidService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/trade_bids")
public class TradeBidController {

    private final TradeBidService service;

    public TradeBidController(TradeBidService service) {
        this.service = service;
    }


    @GetMapping
    public List<TradeBid> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TradeBid> create(@Valid @RequestBody TradeBid entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "TradeBid not found")));
    }


    @GetMapping("/{id}/outbid")
    public ResponseEntity<Boolean> outbidBy(@PathVariable Long id, @RequestParam java.math.BigDecimal newAmount) {
        try {
            return ResponseEntity.ok(service.outbidBy(id, newAmount));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> retract(@PathVariable Long id) {
        try {
            service.retract(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
