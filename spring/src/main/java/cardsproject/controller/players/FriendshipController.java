package cardsproject.controller.players;

import cardsproject.domain.players.Friendship;
import cardsproject.service.players.FriendshipService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/friendships")
public class FriendshipController {

    private final FriendshipService service;

    public FriendshipController(FriendshipService service) {
        this.service = service;
    }


    @GetMapping
    public List<Friendship> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Friendship> create(@Valid @RequestBody Friendship entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
        String currentUserId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
        if (!String.valueOf(entity.getRequesterId()).equals(currentUserId)) {
            return ResponseEntity.status(403).body(java.util.Map.of("error", "Forbidden"));
        }
            return ResponseEntity.ok(entity);
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Friendship not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
        String currentUserId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
        if (!String.valueOf(entity.getRequesterId()).equals(currentUserId)) {
            return ResponseEntity.status(403).body(java.util.Map.of("error", "Forbidden"));
        }
            service.delete(id);
            return ResponseEntity.noContent().build();
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Friendship not found")));
    }


    @PostMapping("/{id}/accept")
    public ResponseEntity<Void> accept(@PathVariable Long id) {
        try {
            service.accept(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/decline")
    public ResponseEntity<Void> decline(@PathVariable Long id) {
        try {
            service.decline(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/block")
    public ResponseEntity<Void> block(@PathVariable Long id) {
        try {
            service.block(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
