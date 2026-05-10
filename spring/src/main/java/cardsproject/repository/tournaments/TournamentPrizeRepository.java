package cardsproject.repository.tournaments;

import cardsproject.domain.tournaments.TournamentPrize;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TournamentPrizeRepository extends JpaRepository<TournamentPrize, Long> {
}
