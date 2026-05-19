package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.TradeDispute;
import cardsproject.service.marketplace.TradeDisputeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/trade_disputes")
public class TradeDisputeController {

    private final TradeDisputeService service;

    public TradeDisputeController(TradeDisputeService service) {
        this.service = service;
    }

    @GetMapping
    public List<TradeDispute> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TradeDispute> create(@Valid @RequestBody TradeDispute entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TradeDispute> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TradeDispute> update(@PathVariable Long id, @Valid @RequestBody TradeDispute entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TradeDispute> patch(@PathVariable Long id, @Valid @RequestBody TradeDispute entity) {
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

    @PostMapping("/{id}/escalate")
    public ResponseEntity<Void> escalate(@PathVariable Long id) {
        service.escalate(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/resolve")
    public ResponseEntity<Void> resolve(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.resolve(id, (String) body.get("resolution_text"));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/close")
    public ResponseEntity<Void> closeResolved(@PathVariable Long id) {
        service.closeResolved(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/review")
    public ResponseEntity<Void> review(@PathVariable Long id) {
        service.review(id);
        return ResponseEntity.noContent().build();
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/open-to-underreview")
    public ResponseEntity<?> transitionOpenToUnderReview(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionOpenToUnderReview(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/underreview-to-resolved")
    public ResponseEntity<?> transitionUnderReviewToResolved(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionUnderReviewToResolved(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/underreview-to-escalated")
    public ResponseEntity<?> transitionUnderReviewToEscalated(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionUnderReviewToEscalated(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/escalated-to-resolved")
    public ResponseEntity<?> transitionEscalatedToResolved(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionEscalatedToResolved(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/transitions/resolved-to-open")
    public ResponseEntity<?> transitionResolvedToOpen(@PathVariable Long id) {
        try {
            service.transitionResolvedToOpen(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        }
    }
}
