package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.TradeListing;
import cardsproject.service.marketplace.TradeListingService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/trade_listings")
public class TradeListingController {

    private final TradeListingService service;

    public TradeListingController(TradeListingService service) {
        this.service = service;
    }


    @GetMapping
    public List<TradeListing> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<TradeListing> create(@Valid @RequestBody TradeListing entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TradeListing> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TradeListing> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }


    @PostMapping("/{id}/close")
    public ResponseEntity<Void> close(@PathVariable Long id) {
        try {
            service.close(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/extend")
    public ResponseEntity<Void> extend(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.extend(id, (Integer) body.get("days"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
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

    @GetMapping("/{id}/expired")
    public ResponseEntity<Boolean> isExpired(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isExpired(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/finalize")
    public ResponseEntity<Void> finalizeAuction(@PathVariable Long id) {
        try {
            service.finalizeAuction(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_SELLER')")
    @PatchMapping("/{id}/transitions/pending-to-active")
    public ResponseEntity<?> transitionPendingToActive(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPendingToActive(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/active-to-sold")
    public ResponseEntity<?> transitionActiveToSold(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionActiveToSold(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/active-to-expired")
    public ResponseEntity<?> transitionActiveToExpired(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionActiveToExpired(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_SELLER')")
    @PatchMapping("/{id}/transitions/active-to-cancelled")
    public ResponseEntity<?> transitionActiveToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionActiveToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/sold-to-active")
    public ResponseEntity<?> transitionSoldToActive(@PathVariable Long id) {
        try {
            service.transitionSoldToActive(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/expired-to-active")
    public ResponseEntity<?> transitionExpiredToActive(@PathVariable Long id) {
        try {
            service.transitionExpiredToActive(id);
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
