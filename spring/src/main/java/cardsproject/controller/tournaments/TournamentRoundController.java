package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentRound;
import cardsproject.service.tournaments.TournamentRoundService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournament_rounds")
public class TournamentRoundController {

    private final TournamentRoundService service;

    public TournamentRoundController(TournamentRoundService service) {
        this.service = service;
    }


    @GetMapping
    public List<TournamentRound> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TournamentRound> create(@Valid @RequestBody TournamentRound entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "TournamentRound not found")));
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

    @PostMapping("/{id}/pairings")
    public ResponseEntity<Void> generatePairings(@PathVariable Long id) {
        try {
            service.generatePairings(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/time-expired")
    public ResponseEntity<Boolean> isTimeExpired(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isTimeExpired(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
