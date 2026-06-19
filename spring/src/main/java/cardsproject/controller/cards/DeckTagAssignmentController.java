package cardsproject.controller.cards;

import cardsproject.domain.cards.DeckTagAssignment;
import cardsproject.service.cards.DeckTagAssignmentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/deck_tag_assignments")
public class DeckTagAssignmentController {

    private final DeckTagAssignmentService service;

    public DeckTagAssignmentController(DeckTagAssignmentService service) {
        this.service = service;
    }


    @GetMapping
    public List<DeckTagAssignment> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<DeckTagAssignment> create(@Valid @RequestBody DeckTagAssignment entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "DeckTagAssignment not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "DeckTagAssignment not found"));
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

}
