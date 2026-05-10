package cardsproject.repository.cards;

import cardsproject.domain.cards.DeckSideboardCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeckSideboardCardRepository extends JpaRepository<DeckSideboardCard, Long> {
}
