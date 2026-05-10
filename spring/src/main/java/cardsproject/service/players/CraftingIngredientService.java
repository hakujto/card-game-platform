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
}
