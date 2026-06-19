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
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "TournamentJudge not found")));
    }


    @PostMapping("/{id}/promote")
    public ResponseEntity<Void> promoteToHead(@PathVariable Long id) {
        try {
            service.promoteToHead(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remove(@PathVariable Long id) {
        try {
            service.remove(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
