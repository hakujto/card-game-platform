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

    @PostMapping
    public ResponseEntity<TradeTransaction> create(@Valid @RequestBody TradeTransaction entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TradeTransaction> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TradeTransaction> update(@PathVariable Long id, @Valid @RequestBody TradeTransaction entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TradeTransaction> patch(@PathVariable Long id, @Valid @RequestBody TradeTransaction entity) {
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

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        service.complete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/refund")
    public ResponseEntity<Void> refund(@PathVariable Long id) {
        service.refund(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/dispute")
    public ResponseEntity<Void> openDispute(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.openDispute(id, (String) body.get("reason"));
        return ResponseEntity.noContent().build();
    }
}
