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

    @GetMapping("/{id}")
    public ResponseEntity<DraftPick> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }


    @GetMapping("/{id}/first-pick")
    public ResponseEntity<Boolean> isFirstPick(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isFirstPick(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
