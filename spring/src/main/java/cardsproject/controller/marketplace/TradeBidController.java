package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.TradeBid;
import cardsproject.service.marketplace.TradeBidService;
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
    public ResponseEntity<TradeBid> create(@RequestBody TradeBid entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TradeBid> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TradeBid> update(@PathVariable Long id, @RequestBody TradeBid entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TradeBid> patch(@PathVariable Long id, @RequestBody TradeBid entity) {
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
