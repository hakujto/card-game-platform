package cardsproject.repository.cards;

import cardsproject.domain.cards.DeckCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeckCardRepository extends JpaRepository<DeckCard, Long> {
}
