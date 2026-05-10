package cardsproject.repository.content;

import cardsproject.domain.content.DraftSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DraftSessionRepository extends JpaRepository<DraftSession, Long> {
}
