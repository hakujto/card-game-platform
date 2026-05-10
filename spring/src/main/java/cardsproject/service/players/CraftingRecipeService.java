package cardsproject.service.players;

import cardsproject.domain.players.CraftingRecipe;
import cardsproject.repository.players.CraftingRecipeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CraftingRecipeService {

    private final CraftingRecipeRepository repository;

    public CraftingRecipeService(CraftingRecipeRepository repository) {
        this.repository = repository;
    }

    public List<CraftingRecipe> findAll() {
        return repository.findAll();
    }

    public Optional<CraftingRecipe> findById(Long id) {
        return repository.findById(id);
    }

    public CraftingRecipe save(CraftingRecipe entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
