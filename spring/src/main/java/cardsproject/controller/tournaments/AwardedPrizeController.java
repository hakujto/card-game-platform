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

    @PostMapping
    public ResponseEntity<AwardedPrize> create(@Valid @RequestBody AwardedPrize entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AwardedPrize> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<AwardedPrize> update(@PathVariable Long id, @Valid @RequestBody AwardedPrize entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<AwardedPrize> patch(@PathVariable Long id, @Valid @RequestBody AwardedPrize entity) {
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
}
