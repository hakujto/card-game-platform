package cardsproject.repository.cards;

import cardsproject.domain.cards.CardRuling;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardRulingRepository extends JpaRepository<CardRuling, Long> {
}
