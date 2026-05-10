package cardsproject.repository.cards;

import cardsproject.domain.cards.CardAbility;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardAbilityRepository extends JpaRepository<CardAbility, Long> {
}
