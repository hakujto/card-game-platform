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
    public List<Stream> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Stream> create(@Valid @RequestBody Stream entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Stream not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Stream entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Stream not found"));
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Stream not found")));
    }


    @PostMapping("/{id}/live")
    public ResponseEntity<Void> goLive(@PathVariable Long id) {
        try {
            service.goLive(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/end")
    public ResponseEntity<Void> end(@PathVariable Long id) {
        try {
            service.end(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/viewers")
    public ResponseEntity<Void> updateViewerPeak(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.updateViewerPeak(id, (Integer) body.get("count"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/duration")
    public ResponseEntity<Integer> durationMinutes(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.durationMinutes(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_STREAMER', 'ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/scheduled-to-live")
    public ResponseEntity<?> transitionScheduledToLive(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionScheduledToLive(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ROLE_STREAMER', 'ROLE_ADMIN')")
    @PatchMapping("/{id}/transitions/live-to-ended")
    public ResponseEntity<?> transitionLiveToEnded(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.transitionLiveToEnded(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/transitions/ended-to-live")
    public ResponseEntity<?> transitionEndedToLive(@PathVariable Long id) {
        try {
            service.transitionEndedToLive(id);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(java.util.Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.unprocessableEntity().body(java.util.Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
