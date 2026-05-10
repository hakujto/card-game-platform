package cardsproject.repository.content;

import cardsproject.domain.content.DraftPick;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DraftPickRepository extends JpaRepository<DraftPick, Long> {
}
