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

    public java.math.BigDecimal winRate(Long id) {
        PlayerSeasonStats entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerSeasonStats not found: " + id));
        java.math.BigDecimal result = entity.winRate();
        repository.save(entity);
        return result;
    }

    public void addPoints(Long id, Integer points) {
        PlayerSeasonStats entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerSeasonStats not found: " + id));
        entity.addPoints(points);
        repository.save(entity);
    }

    public void recordTournamentWin(Long id) {
        PlayerSeasonStats entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerSeasonStats not found: " + id));
        entity.recordTournamentWin();
        repository.save(entity);
    }
}
