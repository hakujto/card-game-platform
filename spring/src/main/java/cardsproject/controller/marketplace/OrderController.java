package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.Order;
import cardsproject.service.marketplace.OrderService;
import jakarta.validation.Valid;
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
    public ResponseEntity<Order> create(@Valid @RequestBody Order entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Order> update(@PathVariable Long id, @Valid @RequestBody Order entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Order> patch(@PathVariable Long id, @Valid @RequestBody Order entity) {
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

    @PostMapping("/{id}/process-payment")
    public ResponseEntity<Boolean> processPayment(@PathVariable Long id) {
        return ResponseEntity.ok(service.processPayment(id));
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

    @PatchMapping("/{id}/transitions/pending-to-paid")
    public ResponseEntity<?> transitionPendingToPaid(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPendingToPaid(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/paid-to-processing")
    public ResponseEntity<?> transitionPaidToProcessing(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPaidToProcessing(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/processing-to-shipped")
    public ResponseEntity<?> transitionProcessingToShipped(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionProcessingToShipped(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/shipped-to-completed")
    public ResponseEntity<?> transitionShippedToCompleted(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionShippedToCompleted(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/transitions/pending-to-cancelled")
    public ResponseEntity<?> transitionPendingToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPendingToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/paid-to-cancelled")
    public ResponseEntity<?> transitionPaidToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPaidToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/completed-to-refunded")
    public ResponseEntity<?> transitionCompletedToRefunded(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionCompletedToRefunded(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/transitions/refunded-to-completed")
    public ResponseEntity<?> transitionRefundedToCompleted(@PathVariable Long id) {
        try {
            service.transitionRefundedToCompleted(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/transitions/completed-to-cancelled")
    public ResponseEntity<?> transitionCompletedToCancelled(@PathVariable Long id) {
        try {
            service.transitionCompletedToCancelled(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }
}
