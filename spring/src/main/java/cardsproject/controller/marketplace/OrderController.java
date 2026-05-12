package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.Order;
import cardsproject.service.marketplace.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    @GetMapping
    public List<Order> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Order> create(@RequestBody Order entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Order> update(@PathVariable Long id, @RequestBody Order entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Order> patch(@PathVariable Long id, @RequestBody Order entity) {
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

    @DeleteMapping("/{id}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        service.cancel(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/pay")
    public ResponseEntity<Boolean> pay(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        return ResponseEntity.ok(service.pay(id, (String) body.get("payment_ref")));
    }

    @GetMapping("/{id}/total")
    public ResponseEntity<java.math.BigDecimal> calculateTotal(@PathVariable Long id) {
        return ResponseEntity.ok(service.calculateTotal(id));
    }

    @PatchMapping("/{id}/discount")
    public ResponseEntity<java.math.BigDecimal> applyDiscount(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        return ResponseEntity.ok(service.applyDiscount(id, (Integer) body.get("percent")));
    }

    @PostMapping("/{id}/refund")
    public ResponseEntity<Void> refund(@PathVariable Long id) {
        service.refund(id);
        return ResponseEntity.noContent().build();
    }
}
