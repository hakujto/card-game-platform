package cardsproject.repository.tournaments;

import cardsproject.domain.tournaments.TournamentJudge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TournamentJudgeRepository extends JpaRepository<TournamentJudge, Long> {
}
