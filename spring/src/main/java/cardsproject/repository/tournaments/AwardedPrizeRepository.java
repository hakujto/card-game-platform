package cardsproject.repository.tournaments;

import cardsproject.domain.tournaments.AwardedPrize;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AwardedPrizeRepository extends JpaRepository<AwardedPrize, Long> {
}
