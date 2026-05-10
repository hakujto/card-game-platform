package cardsproject.repository.players;

import cardsproject.domain.players.CraftingIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CraftingIngredientRepository extends JpaRepository<CraftingIngredient, Long> {
}
