package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.TradeTransaction;
import cardsproject.service.marketplace.TradeTransactionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/trade_transactions")
public class TradeTransactionController {

    private final TradeTransactionService service;

    public TradeTransactionController(TradeTransactionService service) {
        this.service = service;
    }


    @GetMapping
    public List<TradeTransaction> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "TradeTransaction not found")));
    }


    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        try {
            service.complete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/refund")
    public ResponseEntity<Void> refund(@PathVariable Long id) {
        try {
            service.refund(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/dispute")
    public ResponseEntity<Void> openDispute(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.openDispute(id, (String) body.get("reason"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/seller-net")
    public ResponseEntity<java.math.BigDecimal> sellerNet(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.sellerNet(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
