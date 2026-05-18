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

    @PutMapping("/{id}")
    public ResponseEntity<PlayerCollection> update(@PathVariable Long id, @Valid @RequestBody PlayerCollection entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<PlayerCollection> patch(@PathVariable Long id, @Valid @RequestBody PlayerCollection entity) {
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

    @PostMapping("/{id}/add")
    public ResponseEntity<Void> add(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.add(id, (Integer) body.get("quantity"));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/remove")
    public ResponseEntity<Void> remove(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.remove(id, (Integer) body.get("quantity"));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/value")
    public ResponseEntity<java.math.BigDecimal> estimatedValue(@PathVariable Long id) {
        return ResponseEntity.ok(service.estimatedValue(id));
    }
}
