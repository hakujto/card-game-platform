package cardsproject.controller.players;

import cardsproject.domain.players.CraftingIngredient;
import cardsproject.service.players.CraftingIngredientService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/crafting_ingredients")
public class CraftingIngredientController {

    private final CraftingIngredientService service;

    public CraftingIngredientController(CraftingIngredientService service) {
        this.service = service;
    }


    @GetMapping
    public List<CraftingIngredient> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<CraftingIngredient> create(@Valid @RequestBody CraftingIngredient entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "CraftingIngredient not found")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "CraftingIngredient not found"));
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

}
