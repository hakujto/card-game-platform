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

    @PutMapping("/{id}")
    public ResponseEntity<Match> update(@PathVariable Long id, @Valid @RequestBody Match entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Match> patch(@PathVariable Long id, @Valid @RequestBody Match entity) {
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

    @PostMapping("/{id}/record")
    public ResponseEntity<Void> recordResult(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.recordResult(id, (Integer) body.get("p1_wins"), (Integer) body.get("p2_wins"));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/winner")
    public ResponseEntity<Boolean> determineWinner(@PathVariable Long id) {
        return ResponseEntity.ok(service.determineWinner(id));
    }

    @PostMapping("/{id}/concede")
    public ResponseEntity<Void> concede(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.concede(id, (Integer) body.get("player_id"));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/draw")
    public ResponseEntity<Void> draw(@PathVariable Long id) {
        service.draw(id);
        return ResponseEntity.noContent().build();
    }
}
