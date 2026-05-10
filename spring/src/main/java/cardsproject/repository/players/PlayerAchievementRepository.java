package cardsproject.repository.players;

import cardsproject.domain.players.PlayerAchievement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayerAchievementRepository extends JpaRepository<PlayerAchievement, Long> {
}
