package cardsproject.repository.cards;

import cardsproject.domain.cards.DeckTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeckTagRepository extends JpaRepository<DeckTag, Long> {
}
