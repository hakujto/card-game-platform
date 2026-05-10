package cardsproject.repository.content;

import cardsproject.domain.content.DraftParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DraftParticipantRepository extends JpaRepository<DraftParticipant, Long> {
}
