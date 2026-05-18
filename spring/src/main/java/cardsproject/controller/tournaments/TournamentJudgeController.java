package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.TournamentJudge;
import cardsproject.service.tournaments.TournamentJudgeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournament_judges")
public class TournamentJudgeController {

    private final TournamentJudgeService service;

    public TournamentJudgeController(TournamentJudgeService service) {
        this.service = service;
    }

    @GetMapping
    public List<TournamentJudge> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<TournamentJudge> create(@Valid @RequestBody TournamentJudge entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TournamentJudge> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TournamentJudge> update(@PathVariable Long id, @Valid @RequestBody TournamentJudge entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TournamentJudge> patch(@PathVariable Long id, @Valid @RequestBody TournamentJudge entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }


    @PostMapping("/{id}/promote")
    public ResponseEntity<Void> promoteToHead(@PathVariable Long id) {
        service.promoteToHead(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remove(@PathVariable Long id) {
        service.remove(id);
        return ResponseEntity.noContent().build();
    }
}
