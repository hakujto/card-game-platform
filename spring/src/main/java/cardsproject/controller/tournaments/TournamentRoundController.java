package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentRound;
import cardsproject.service.tournaments.TournamentRoundService;
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
    public ResponseEntity<TournamentRound> create(@RequestBody TournamentRound entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TournamentRound> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TournamentRound> update(@PathVariable Long id, @RequestBody TournamentRound entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TournamentRound> patch(@PathVariable Long id, @RequestBody TournamentRound entity) {
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
}
