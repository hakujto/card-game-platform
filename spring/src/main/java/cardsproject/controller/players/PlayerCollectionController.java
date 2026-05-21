package cardsproject.controller.players;

import cardsproject.domain.players.PlayerCollection;
import cardsproject.service.players.PlayerCollectionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/player_collections")
public class PlayerCollectionController {

    private final PlayerCollectionService service;

    public PlayerCollectionController(PlayerCollectionService service) {
        this.service = service;
    }


    @GetMapping
    public List<PlayerCollection> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<PlayerCollection> create(@Valid @RequestBody PlayerCollection entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlayerCollection> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}")
    public ResponseEntity<PlayerCollection> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @PostMapping("/{id}/add")
    public ResponseEntity<Void> add(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.add(id, (Integer) body.get("quantity"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/remove")
    public ResponseEntity<Void> remove(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.remove(id, (Integer) body.get("quantity"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/value")
    public ResponseEntity<java.math.BigDecimal> estimatedValue(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.estimatedValue(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
