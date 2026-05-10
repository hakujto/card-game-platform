package cardsproject.repository.players;

import cardsproject.domain.players.PlayerCollection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayerCollectionRepository extends JpaRepository<PlayerCollection, Long> {
}
