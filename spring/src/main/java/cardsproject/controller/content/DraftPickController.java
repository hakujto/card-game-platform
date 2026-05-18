package cardsproject.controller.content;

import cardsproject.domain.content.DraftPick;
import cardsproject.service.content.DraftPickService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/draft_picks")
public class DraftPickController {

    private final DraftPickService service;

    public DraftPickController(DraftPickService service) {
        this.service = service;
    }

    @GetMapping
    public List<DraftPick> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DraftPick> create(@Valid @RequestBody DraftPick entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DraftPick> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DraftPick> update(@PathVariable Long id, @Valid @RequestBody DraftPick entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DraftPick> patch(@PathVariable Long id, @Valid @RequestBody DraftPick entity) {
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

    @GetMapping("/{id}/first-pick")
    public ResponseEntity<Boolean> isFirstPick(@PathVariable Long id) {
        return ResponseEntity.ok(service.isFirstPick(id));
    }
}
