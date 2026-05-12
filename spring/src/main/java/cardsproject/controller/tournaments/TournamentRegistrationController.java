package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentRegistration;
import cardsproject.service.tournaments.TournamentRegistrationService;
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
    public ResponseEntity<TournamentRegistration> create(@RequestBody TournamentRegistration entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TournamentRegistration> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TournamentRegistration> update(@PathVariable Long id, @RequestBody TournamentRegistration entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TournamentRegistration> patch(@PathVariable Long id, @RequestBody TournamentRegistration entity) {
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

    @PostMapping("/{id}/withdraw")
    public ResponseEntity<Void> withdraw(@PathVariable Long id) {
        service.withdraw(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/disqualify")
    public ResponseEntity<Void> disqualify(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.disqualify(id, (String) body.get("reason"));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/promote")
    public ResponseEntity<Void> promoteFromWaitlist(@PathVariable Long id) {
        service.promoteFromWaitlist(id);
        return ResponseEntity.noContent().build();
    }
}
