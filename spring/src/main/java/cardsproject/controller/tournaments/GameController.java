package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.Game;
import cardsproject.service.tournaments.GameService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/games")
public class GameController {

    private final GameService service;

    public GameController(GameService service) {
        this.service = service;
    }


    @GetMapping
    public List<Game> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Game> create(@Valid @RequestBody Game entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Game not found")));
    }


    @PostMapping("/{id}/winner")
    public ResponseEntity<Void> recordWinner(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.recordWinner(id, (String) body.get("winner_side"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/duration")
    public ResponseEntity<java.math.BigDecimal> durationMinutes(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.durationMinutes(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
