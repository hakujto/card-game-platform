package cardsproject.controller.players;

import cardsproject.domain.players.Player;
import cardsproject.service.players.PlayerService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/players")
public class PlayerController {

    private final PlayerService service;

    public PlayerController(PlayerService service) {
        this.service = service;
    }


    @GetMapping
    public List<Player> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Player> create(@Valid @RequestBody Player entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Player not found")));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Player not found")));
    }


    @PostMapping("/{id}/promote")
    public ResponseEntity<Boolean> promote(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.promote(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/demote")
    public ResponseEntity<Boolean> demote(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.demote(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/win")
    public ResponseEntity<Void> recordWin(@PathVariable Long id) {
        try {
            service.recordWin(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/loss")
    public ResponseEntity<Void> recordLoss(@PathVariable Long id) {
        try {
            service.recordLoss(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
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

    @PostMapping("/{id}/verify")
    public ResponseEntity<Void> verify(@PathVariable Long id) {
        try {
            service.verify(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/rating")
    public ResponseEntity<Void> updateRating(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.updateRating(id, (Integer) body.get("delta"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
