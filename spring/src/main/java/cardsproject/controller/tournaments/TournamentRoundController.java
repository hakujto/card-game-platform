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
    public ResponseEntity<TournamentRound> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TournamentRound> update(@PathVariable Long id, @Valid @RequestBody TournamentRound entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TournamentRound> patch(@PathVariable Long id, @Valid @RequestBody TournamentRound entity) {
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

    @PostMapping("/{id}/start")
    public ResponseEntity<Void> start(@PathVariable Long id) {
        service.start(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        service.complete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/pairings")
    public ResponseEntity<Void> generatePairings(@PathVariable Long id) {
        service.generatePairings(id);
        return ResponseEntity.noContent().build();
    }
}
