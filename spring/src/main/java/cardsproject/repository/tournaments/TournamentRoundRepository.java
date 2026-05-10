package cardsproject.repository.tournaments;

import cardsproject.domain.tournaments.TournamentRound;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TournamentRoundRepository extends JpaRepository<TournamentRound, Long> {
}
