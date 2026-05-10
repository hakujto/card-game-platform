package cardsproject.repository.cards;

import cardsproject.domain.cards.DeckTagAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeckTagAssignmentRepository extends JpaRepository<DeckTagAssignment, Long> {
}
