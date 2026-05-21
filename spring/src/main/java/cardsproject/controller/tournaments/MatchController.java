package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.Match;
import cardsproject.service.tournaments.MatchService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/matches")
public class MatchController {

    private final MatchService service;

    public MatchController(MatchService service) {
        this.service = service;
    }


    @GetMapping
    public List<Match> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Match> create(@Valid @RequestBody Match entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Match> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }


    @PostMapping("/{id}/record")
    public ResponseEntity<Void> recordResult(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.recordResult(id, (Integer) body.get("p1_wins"), (Integer) body.get("p2_wins"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/finalize")
    public ResponseEntity<Void> finalizeResult(@PathVariable Long id) {
        try {
            service.finalizeResult(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/winner")
    public ResponseEntity<Boolean> determineWinner(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.determineWinner(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/concede")
    public ResponseEntity<Void> concede(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.concede(id, (Integer) body.get("player_id"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/draw")
    public ResponseEntity<Void> draw(@PathVariable Long id) {
        try {
            service.draw(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_JUDGE')")
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

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_JUDGE')")
    @PatchMapping("/{id}/transitions/active-to-completed")
    public ResponseEntity<?> transitionActiveToCompleted(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionActiveToCompleted(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_JUDGE')")
    @PatchMapping("/{id}/transitions/active-to-draw")
    public ResponseEntity<?> transitionActiveToDraw(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionActiveToDraw(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_JUDGE')")
    @PatchMapping("/{id}/transitions/pending-to-bye")
    public ResponseEntity<?> transitionPendingToBYE(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionPendingToBYE(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/completed-to-active")
    public ResponseEntity<?> transitionCompletedToActive(@PathVariable Long id) {
        try {
            service.transitionCompletedToActive(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/draw-to-active")
    public ResponseEntity<?> transitionDrawToActive(@PathVariable Long id) {
        try {
            service.transitionDrawToActive(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/bye-to-active")
    public ResponseEntity<?> transitionBYEToActive(@PathVariable Long id) {
        try {
            service.transitionBYEToActive(id);
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
