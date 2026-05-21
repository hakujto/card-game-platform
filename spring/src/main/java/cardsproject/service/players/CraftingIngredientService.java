package cardsproject.service.players;

import cardsproject.domain.players.CraftingIngredient;
import cardsproject.repository.players.CraftingIngredientRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CraftingIngredientService {

    private final CraftingIngredientRepository repository;

    public CraftingIngredientService(CraftingIngredientRepository repository) {
        this.repository = repository;
    }

    public List<CraftingIngredient> findAll() {
        return repository.findAll();
    }

    public Optional<CraftingIngredient> findById(Long id) {
        return repository.findById(id);
    }

    public CraftingIngredient save(CraftingIngredient entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(CraftingIngredient entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("quantity") && patch.get("quantity") != null) entity.setQuantity(Integer.valueOf(patch.get("quantity").toString()));
        if (patch.containsKey("recipeId") && patch.get("recipeId") != null) entity.setRecipeId(Long.valueOf(patch.get("recipeId").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
    }
}
