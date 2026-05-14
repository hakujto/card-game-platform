package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentPrize;
import cardsproject.service.tournaments.TournamentPrizeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournament_prizes")
public class TournamentPrizeController {

    private final TournamentPrizeService service;

    public TournamentPrizeController(TournamentPrizeService service) {
        this.service = service;
    }

    @GetMapping
    public List<TournamentPrize> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TournamentPrize> create(@Valid @RequestBody TournamentPrize entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TournamentPrize> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TournamentPrize> update(@PathVariable Long id, @Valid @RequestBody TournamentPrize entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TournamentPrize> patch(@PathVariable Long id, @Valid @RequestBody TournamentPrize entity) {
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
