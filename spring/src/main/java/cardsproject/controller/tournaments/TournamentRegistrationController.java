package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentRegistration;
import cardsproject.service.tournaments.TournamentRegistrationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournament_registrations")
public class TournamentRegistrationController {

    private final TournamentRegistrationService service;

    public TournamentRegistrationController(TournamentRegistrationService service) {
        this.service = service;
    }


    @GetMapping
    public List<TournamentRegistration> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TournamentRegistration> create(@Valid @RequestBody TournamentRegistration entity) {
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
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "TournamentRegistration not found")));
    }


    @PostMapping("/{id}/withdraw")
    public ResponseEntity<Void> withdraw(@PathVariable Long id) {
        try {
            service.withdraw(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/disqualify")
    public ResponseEntity<Void> disqualify(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.disqualify(id, (String) body.get("reason"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/promote")
    public ResponseEntity<Void> promoteFromWaitlist(@PathVariable Long id) {
        try {
            service.promoteFromWaitlist(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
