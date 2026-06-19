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
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
        String currentUserId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
        if (!String.valueOf(entity.getPlayerId()).equals(currentUserId)) {
            return ResponseEntity.status(403).body(java.util.Map.of("error", "Forbidden"));
        }
            return ResponseEntity.ok(entity);
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Order not found")));
    }


    @DeleteMapping("/{id}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        try {
            service.cancel(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/pay")
    public ResponseEntity<Boolean> pay(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            return ResponseEntity.ok(service.pay(id, (String) body.get("payment_ref")));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/process-payment")
    public ResponseEntity<Boolean> processPayment(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.processPayment(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/total")
    public ResponseEntity<java.math.BigDecimal> calculateTotal(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.calculateTotal(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/discount")
    public ResponseEntity<java.math.BigDecimal> applyDiscount(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            return ResponseEntity.ok(service.applyDiscount(id, (Integer) body.get("percent")));
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

    @PatchMapping("/{id}/transitions/pending-to-paid")
    public ResponseEntity<?> transitionPendingToPaid(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPendingToPaid(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_STAFF')")
    @PatchMapping("/{id}/transitions/paid-to-processing")
    public ResponseEntity<?> transitionPaidToProcessing(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPaidToProcessing(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_STAFF')")
    @PatchMapping("/{id}/transitions/processing-to-shipped")
    public ResponseEntity<?> transitionProcessingToShipped(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionProcessingToShipped(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_STAFF')")
    @PatchMapping("/{id}/transitions/shipped-to-completed")
    public ResponseEntity<?> transitionShippedToCompleted(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionShippedToCompleted(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
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
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_STAFF')")
    @PatchMapping("/{id}/transitions/paid-to-cancelled")
    public ResponseEntity<?> transitionPaidToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPaidToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
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
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
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
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
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
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
