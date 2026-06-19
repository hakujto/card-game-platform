package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.OrderItem;
import cardsproject.service.marketplace.OrderItemService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/order_items")
public class OrderItemController {

    private final OrderItemService service;

    public OrderItemController(OrderItemService service) {
        this.service = service;
    }


    @GetMapping
    public List<OrderItem> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<OrderItem> create(@Valid @RequestBody OrderItem entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "OrderItem not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "OrderItem not found"));
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/{id}/total")
    public ResponseEntity<java.math.BigDecimal> lineTotal(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.lineTotal(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
