package cardsproject.repository.players;

import cardsproject.domain.players.CraftingRecipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CraftingRecipeRepository extends JpaRepository<CraftingRecipe, Long> {
}
