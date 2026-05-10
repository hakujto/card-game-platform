package cardsproject.controller.players;

import cardsproject.domain.players.CraftingRecipe;
import cardsproject.service.players.CraftingRecipeService;
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
    public ResponseEntity<CraftingRecipe> create(@RequestBody CraftingRecipe entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CraftingRecipe> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<CraftingRecipe> update(@PathVariable Long id, @RequestBody CraftingRecipe entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CraftingRecipe> patch(@PathVariable Long id, @RequestBody CraftingRecipe entity) {
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
