package cardsproject.controller.players;

import cardsproject.domain.players.PlayerAchievement;
import cardsproject.service.players.PlayerAchievementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/player_achievements")
public class PlayerAchievementController {

    private final PlayerAchievementService service;

    public PlayerAchievementController(PlayerAchievementService service) {
        this.service = service;
    }

    @GetMapping
    public List<PlayerAchievement> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<PlayerAchievement> create(@Valid @RequestBody PlayerAchievement entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlayerAchievement> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlayerAchievement> update(@PathVariable Long id, @Valid @RequestBody PlayerAchievement entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<PlayerAchievement> patch(@PathVariable Long id, @Valid @RequestBody PlayerAchievement entity) {
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

    @PatchMapping("/{id}/progress")
    public ResponseEntity<Void> incrementProgress(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.incrementProgress(id, (Integer) body.get("amount"));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        service.complete(id);
        return ResponseEntity.noContent().build();
    }
}
