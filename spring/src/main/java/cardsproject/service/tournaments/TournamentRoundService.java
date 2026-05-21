package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentRound;
import cardsproject.repository.tournaments.TournamentRoundRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentRoundStatusType;

@Service
public class TournamentRoundService {

    private final TournamentRoundRepository repository;

    public TournamentRoundService(TournamentRoundRepository repository) {
        this.repository = repository;
    }

    public List<TournamentRound> findAll() {
        return repository.findAll();
    }

    public Optional<TournamentRound> findById(Long id) {
        return repository.findById(id);
    }

    public TournamentRound save(TournamentRound entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(TournamentRound entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("roundNumber") && patch.get("roundNumber") != null) entity.setRoundNumber(Integer.valueOf(patch.get("roundNumber").toString()));
        if (patch.containsKey("status")) entity.setStatus(TournamentRoundStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("startedAt") && patch.get("startedAt") != null) entity.setStartedAt(java.time.LocalDateTime.parse(patch.get("startedAt").toString()));
        if (patch.containsKey("endedAt") && patch.get("endedAt") != null) entity.setEndedAt(java.time.LocalDateTime.parse(patch.get("endedAt").toString()));
        if (patch.containsKey("timeLimitMinutes") && patch.get("timeLimitMinutes") != null) entity.setTimeLimitMinutes(Integer.valueOf(patch.get("timeLimitMinutes").toString()));
        if (patch.containsKey("tournamentId") && patch.get("tournamentId") != null) entity.setTournamentId(Long.valueOf(patch.get("tournamentId").toString()));
    }
    private void validate(TournamentRound entity) {
        if (entity.getEndedAt() != null && !((entity.getEndedAt() == null || (entity.getStartedAt() != null && entity.getEndedAt().isAfter(entity.getStartedAt()))))) throw new IllegalStateException("Round end time must be after start time");
        if (TournamentRoundStatusType.COMPLETED.equals(entity.getStatus()) && entity.getStartedAt() == null) throw new IllegalStateException("Completed round must have a start time");
    }

    public void start(Long id) {
        TournamentRound entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRound not found: " + id));
        entity.start();
        repository.save(entity);
    }

    public void complete(Long id) {
        TournamentRound entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRound not found: " + id));
        entity.complete();
        repository.save(entity);
    }

    public void generatePairings(Long id) {
        TournamentRound entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRound not found: " + id));
        entity.generatePairings();
        repository.save(entity);
    }

    public Boolean isTimeExpired(Long id) {
        TournamentRound entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRound not found: " + id));
        Boolean result = entity.isTimeExpired();
        repository.save(entity);
        return result;
    }
}
