package cardsproject.repository.cards;

import cardsproject.domain.cards.CardSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardSetRepository extends JpaRepository<CardSet, Long> {
}
