package cardsproject.controller.content;

import cardsproject.domain.content.DraftSession;
import cardsproject.service.content.DraftSessionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/draft_sessions")
public class DraftSessionController {

    private final DraftSessionService service;

    public DraftSessionController(DraftSessionService service) {
        this.service = service;
    }

    @GetMapping
    public List<DraftSession> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DraftSession> create(@RequestBody DraftSession entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DraftSession> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DraftSession> update(@PathVariable Long id, @RequestBody DraftSession entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DraftSession> patch(@PathVariable Long id, @RequestBody DraftSession entity) {
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

    @PostMapping("/{id}/start")
    public ResponseEntity<Void> start(@PathVariable Long id) {
        service.start(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/abandon")
    public ResponseEntity<Void> abandon(@PathVariable Long id) {
        service.abandon(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Void> complete(@PathVariable Long id) {
        service.complete(id);
        return ResponseEntity.noContent().build();
    }
}
