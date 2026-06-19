package cardsproject.controller.players;

import cardsproject.domain.players.Achievement;
import cardsproject.service.players.AchievementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/achievements")
public class AchievementController {

    private final AchievementService service;

    public AchievementController(AchievementService service) {
        this.service = service;
    }


    @GetMapping
    public List<Achievement> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Achievement> create(@Valid @RequestBody Achievement entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Achievement not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Achievement entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Achievement not found"));
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Achievement not found")));
    }


    @GetMapping("/{id}/point-value")
    public ResponseEntity<Integer> pointValue(@PathVariable Long id, @RequestParam Integer multiplier) {
        try {
            return ResponseEntity.ok(service.pointValue(id, multiplier));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/reveal")
    public ResponseEntity<Void> reveal(@PathVariable Long id) {
        try {
            service.reveal(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
