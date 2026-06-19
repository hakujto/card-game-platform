package cardsproject.controller.tournaments;

import cardsproject.domain.tournaments.AwardedPrize;
import cardsproject.service.tournaments.AwardedPrizeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/awarded_prizes")
public class AwardedPrizeController {

    private final AwardedPrizeService service;

    public AwardedPrizeController(AwardedPrizeService service) {
        this.service = service;
    }


    @GetMapping
    public List<AwardedPrize> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "AwardedPrize not found")));
    }


    @PostMapping("/{id}/claim")
    public ResponseEntity<Void> claim(@PathVariable Long id) {
        try {
            service.claim(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
