package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.Match;
import cardsproject.service.tournaments.MatchService;
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
    public ResponseEntity<Match> create(@RequestBody Match entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Match> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Match> update(@PathVariable Long id, @RequestBody Match entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Match> patch(@PathVariable Long id, @RequestBody Match entity) {
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

    @GetMapping("/{id}/winner")
    public ResponseEntity<Boolean> determineWinner(@PathVariable Long id) {
        return ResponseEntity.ok(service.determineWinner(id));
    }

    @PostMapping("/{id}/draw")
    public ResponseEntity<Void> draw(@PathVariable Long id) {
        service.draw(id);
        return ResponseEntity.noContent().build();
    }
}
