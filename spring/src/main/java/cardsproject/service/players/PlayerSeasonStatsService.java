package cardsproject.service.players;

import cardsproject.domain.players.PlayerSeasonStats;
import cardsproject.repository.players.PlayerSeasonStatsRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.players.PlayerSeasonStatsHighestRankType;

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

    public void applyPatch(PlayerSeasonStats entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("wins") && patch.get("wins") != null) entity.setWins(Integer.valueOf(patch.get("wins").toString()));
        if (patch.containsKey("losses") && patch.get("losses") != null) entity.setLosses(Integer.valueOf(patch.get("losses").toString()));
        if (patch.containsKey("draws") && patch.get("draws") != null) entity.setDraws(Integer.valueOf(patch.get("draws").toString()));
        if (patch.containsKey("tournamentWins") && patch.get("tournamentWins") != null) entity.setTournamentWins(Integer.valueOf(patch.get("tournamentWins").toString()));
        if (patch.containsKey("highestRank")) entity.setHighestRank(PlayerSeasonStatsHighestRankType.valueOf(patch.get("highestRank").toString()));
        if (patch.containsKey("seasonPoints") && patch.get("seasonPoints") != null) entity.setSeasonPoints(Integer.valueOf(patch.get("seasonPoints").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
        if (patch.containsKey("seasonId") && patch.get("seasonId") != null) entity.setSeasonId(Long.valueOf(patch.get("seasonId").toString()));
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
