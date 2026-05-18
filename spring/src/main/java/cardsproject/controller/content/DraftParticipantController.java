package cardsproject.controller.content;

import cardsproject.domain.content.DraftParticipant;
import cardsproject.service.content.DraftParticipantService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/draft_participants")
public class DraftParticipantController {

    private final DraftParticipantService service;

    public DraftParticipantController(DraftParticipantService service) {
        this.service = service;
    }

    @GetMapping
    public List<DraftParticipant> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DraftParticipant> create(@Valid @RequestBody DraftParticipant entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DraftParticipant> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DraftParticipant> update(@PathVariable Long id, @Valid @RequestBody DraftParticipant entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DraftParticipant> patch(@PathVariable Long id, @Valid @RequestBody DraftParticipant entity) {
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

    @PostMapping("/{id}/pick")
    public ResponseEntity<Void> pickCard(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.pickCard(id, (Integer) body.get("card_id"), (Integer) body.get("pack_number"));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/card-count")
    public ResponseEntity<Integer> draftedCardCount(@PathVariable Long id) {
        return ResponseEntity.ok(service.draftedCardCount(id));
    }
}
