package cardsproject.controller.content;

import cardsproject.domain.content.Stream;
import cardsproject.service.content.StreamService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/streams")
public class StreamController {

    private final StreamService service;

    public StreamController(StreamService service) {
        this.service = service;
    }

    @GetMapping
    public List<Stream> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Stream> create(@Valid @RequestBody Stream entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Stream> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Stream> update(@PathVariable Long id, @Valid @RequestBody Stream entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Stream> patch(@PathVariable Long id, @Valid @RequestBody Stream entity) {
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

    @PostMapping("/{id}/live")
    public ResponseEntity<Void> goLive(@PathVariable Long id) {
        service.goLive(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/end")
    public ResponseEntity<Void> end(@PathVariable Long id) {
        service.end(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/viewers")
    public ResponseEntity<Void> updateViewerPeak(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.updateViewerPeak(id, (Integer) body.get("count"));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/duration")
    public ResponseEntity<Integer> durationMinutes(@PathVariable Long id) {
        return ResponseEntity.ok(service.durationMinutes(id));
    }
}
