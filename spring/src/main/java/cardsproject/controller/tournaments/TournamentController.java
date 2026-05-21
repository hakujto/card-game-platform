package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.Tournament;
import cardsproject.service.tournaments.TournamentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournaments")
public class TournamentController {

    private final TournamentService service;

    public TournamentController(TournamentService service) {
        this.service = service;
    }


    @GetMapping
    public List<Tournament> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Tournament> create(@Valid @RequestBody Tournament entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tournament> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tournament> update(@PathVariable Long id, @Valid @RequestBody Tournament entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Tournament> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
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

    @PostMapping("/{id}/cancel")
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

    @PostMapping("/{id}/rounds")
    public ResponseEntity<Void> generateRound(@PathVariable Long id) {
        try {
            service.generateRound(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/prizes")
    public ResponseEntity<java.math.BigDecimal> calculatePrizeDistribution(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.calculatePrizeDistribution(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/register")
    public ResponseEntity<Void> registerPlayer(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.registerPlayer(id, (Integer) body.get("player_id"), (Integer) body.get("deck_id"));
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

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/draft-to-registration")
    public ResponseEntity<?> transitionDraftToRegistration(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionDraftToRegistration(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/registration-to-ongoing")
    public ResponseEntity<?> transitionRegistrationToOngoing(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionRegistrationToOngoing(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/registration-to-cancelled")
    public ResponseEntity<?> transitionRegistrationToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionRegistrationToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/ongoing-to-completed")
    public ResponseEntity<?> transitionOngoingToCompleted(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionOngoingToCompleted(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/ongoing-to-cancelled")
    public ResponseEntity<?> transitionOngoingToCancelled(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionOngoingToCancelled(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/completed-to-draft")
    public ResponseEntity<?> transitionCompletedToDraft(@PathVariable Long id) {
        try {
            service.transitionCompletedToDraft(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/cancelled-to-draft")
    public ResponseEntity<?> transitionCancelledToDraft(@PathVariable Long id) {
        try {
            service.transitionCancelledToDraft(id);
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
