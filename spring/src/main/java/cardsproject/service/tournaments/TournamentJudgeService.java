package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentJudge;
import cardsproject.repository.tournaments.TournamentJudgeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentJudgeRoleType;

@Service
public class TournamentJudgeService {

    private final TournamentJudgeRepository repository;

    public TournamentJudgeService(TournamentJudgeRepository repository) {
        this.repository = repository;
    }

    public List<TournamentJudge> findAll() {
        return repository.findAll();
    }

    public Optional<TournamentJudge> findById(Long id) {
        return repository.findById(id);
    }

    public TournamentJudge save(TournamentJudge entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(TournamentJudge entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("role")) entity.setRole(TournamentJudgeRoleType.valueOf(patch.get("role").toString()));
        if (patch.containsKey("tournamentId") && patch.get("tournamentId") != null) entity.setTournamentId(Long.valueOf(patch.get("tournamentId").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
    }

    public void promoteToHead(Long id) {
        TournamentJudge entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentJudge not found: " + id));
        entity.promoteToHead();
        repository.save(entity);
    }

    public void remove(Long id) {
        TournamentJudge entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentJudge not found: " + id));
        entity.remove();
        repository.save(entity);
    }
}
