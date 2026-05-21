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

    @GetMapping("/{id}")
    public ResponseEntity<PlayerAchievement> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }


    @PatchMapping("/{id}/progress")
    public ResponseEntity<Void> incrementProgress(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.incrementProgress(id, (Integer) body.get("amount"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        try {
            service.complete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
