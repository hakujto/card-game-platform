package cardsproject.controller.players;

import cardsproject.domain.players.PlayerSeasonStats;
import cardsproject.service.players.PlayerSeasonStatsService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/player_season_statses")
public class PlayerSeasonStatsController {

    private final PlayerSeasonStatsService service;

    public PlayerSeasonStatsController(PlayerSeasonStatsService service) {
        this.service = service;
    }

    @GetMapping
    public List<PlayerSeasonStats> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<PlayerSeasonStats> create(@Valid @RequestBody PlayerSeasonStats entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlayerSeasonStats> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlayerSeasonStats> update(@PathVariable Long id, @Valid @RequestBody PlayerSeasonStats entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<PlayerSeasonStats> patch(@PathVariable Long id, @Valid @RequestBody PlayerSeasonStats entity) {
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
