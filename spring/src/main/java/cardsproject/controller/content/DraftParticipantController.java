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


    @PostMapping("/{id}/pick")
    public ResponseEntity<Void> pickCard(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.pickCard(id, (Integer) body.get("card_id"), (Integer) body.get("pack_number"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/card-count")
    public ResponseEntity<Integer> draftedCardCount(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.draftedCardCount(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
