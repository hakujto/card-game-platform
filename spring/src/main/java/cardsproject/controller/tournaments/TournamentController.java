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
    public List<Tournament> list() {
        return service.findAll();
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
    public ResponseEntity<Tournament> patch(@PathVariable Long id, @Valid @RequestBody Tournament entity) {
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

    @PostMapping("/{id}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        service.cancel(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        service.complete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/rounds")
    public ResponseEntity<Void> generateRound(@PathVariable Long id) {
        service.generateRound(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/prizes")
    public ResponseEntity<java.math.BigDecimal> calculatePrizeDistribution(@PathVariable Long id) {
        return ResponseEntity.ok(service.calculatePrizeDistribution(id));
    }
}
