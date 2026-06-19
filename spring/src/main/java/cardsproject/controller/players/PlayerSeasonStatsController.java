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

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "PlayerSeasonStats not found")));
    }


    @GetMapping("/{id}/win-rate")
    public ResponseEntity<java.math.BigDecimal> winRate(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.winRate(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/points")
    public ResponseEntity<Void> addPoints(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.addPoints(id, (Integer) body.get("points"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/tournament-win")
    public ResponseEntity<Void> recordTournamentWin(@PathVariable Long id) {
        try {
            service.recordTournamentWin(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
