package cardsproject.controller.content;

import cardsproject.domain.content.DraftSession;
import cardsproject.service.content.DraftSessionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/draft_sessions")
public class DraftSessionController {

    private final DraftSessionService service;

    public DraftSessionController(DraftSessionService service) {
        this.service = service;
    }


    @GetMapping
    public List<DraftSession> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DraftSession> create(@Valid @RequestBody DraftSession entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DraftSession> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }


    @PostMapping("/{id}/start")
    public ResponseEntity<Void> start(@PathVariable Long id) {
        try {
            service.start(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/abandon")
    public ResponseEntity<Void> abandon(@PathVariable Long id) {
        try {
            service.abandon(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
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

    @GetMapping("/{id}/full")
    public ResponseEntity<Boolean> isFull(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isFull(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/waitingforplayers-to-drafting")
    public ResponseEntity<?> transitionWaitingForPlayersToDrafting(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionWaitingForPlayersToDrafting(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/drafting-to-completed")
    public ResponseEntity<?> transitionDraftingToCompleted(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionDraftingToCompleted(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/drafting-to-abandoned")
    public ResponseEntity<?> transitionDraftingToAbandoned(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionDraftingToAbandoned(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/waitingforplayers-to-abandoned")
    public ResponseEntity<?> transitionWaitingForPlayersToAbandoned(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionWaitingForPlayersToAbandoned(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/completed-to-drafting")
    public ResponseEntity<?> transitionCompletedToDrafting(@PathVariable Long id) {
        try {
            service.transitionCompletedToDrafting(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/abandoned-to-drafting")
    public ResponseEntity<?> transitionAbandonedToDrafting(@PathVariable Long id) {
        try {
            service.transitionAbandonedToDrafting(id);
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
