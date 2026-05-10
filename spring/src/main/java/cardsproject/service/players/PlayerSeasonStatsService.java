package cardsproject.service.players;

import cardsproject.domain.players.PlayerSeasonStats;
import cardsproject.repository.players.PlayerSeasonStatsRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PlayerSeasonStatsService {

    private final PlayerSeasonStatsRepository repository;

    public PlayerSeasonStatsService(PlayerSeasonStatsRepository repository) {
        this.repository = repository;
    }

    public List<PlayerSeasonStats> findAll() {
        return repository.findAll();
    }

    public Optional<PlayerSeasonStats> findById(Long id) {
        return repository.findById(id);
    }

    public PlayerSeasonStats save(PlayerSeasonStats entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
