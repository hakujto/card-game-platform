package cardsproject.controller.players;

import cardsproject.domain.players.CraftingRecipe;
import cardsproject.service.players.CraftingRecipeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/crafting_recipes")
public class CraftingRecipeController {

    private final CraftingRecipeService service;

    public CraftingRecipeController(CraftingRecipeService service) {
        this.service = service;
    }


    @GetMapping
    public List<CraftingRecipe> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CraftingRecipe> create(@Valid @RequestBody CraftingRecipe entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CraftingRecipe> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CraftingRecipe> update(@PathVariable Long id, @Valid @RequestBody CraftingRecipe entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CraftingRecipe> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }


    @GetMapping("/{id}/can-craft")
    public ResponseEntity<Boolean> canCraft(@PathVariable Long id, @RequestParam Integer playerId) {
        try {
            return ResponseEntity.ok(service.canCraft(id, playerId));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/craft")
    public ResponseEntity<Void> executeCraft(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.executeCraft(id, (Integer) body.get("player_id"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/disable")
    public ResponseEntity<Void> disable(@PathVariable Long id) {
        try {
            service.disable(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/enable")
    public ResponseEntity<Void> enable(@PathVariable Long id) {
        try {
            service.enable(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
