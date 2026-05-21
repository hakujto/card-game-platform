package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentRegistration;
import cardsproject.repository.tournaments.TournamentRegistrationRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentRegistrationStatusType;

@Service
public class TournamentRegistrationService {

    private final TournamentRegistrationRepository repository;

    public TournamentRegistrationService(TournamentRegistrationRepository repository) {
        this.repository = repository;
    }

    public List<TournamentRegistration> findAll() {
        return repository.findAll();
    }

    public Optional<TournamentRegistration> findById(Long id) {
        return repository.findById(id);
    }

    public TournamentRegistration save(TournamentRegistration entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(TournamentRegistration entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("status")) entity.setStatus(TournamentRegistrationStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("seed") && patch.get("seed") != null) entity.setSeed(Integer.valueOf(patch.get("seed").toString()));
        if (patch.containsKey("finalStanding") && patch.get("finalStanding") != null) entity.setFinalStanding(Integer.valueOf(patch.get("finalStanding").toString()));
        if (patch.containsKey("pointsEarned") && patch.get("pointsEarned") != null) entity.setPointsEarned(Integer.valueOf(patch.get("pointsEarned").toString()));
        if (patch.containsKey("registeredAt") && patch.get("registeredAt") != null) entity.setRegisteredAt(java.time.LocalDateTime.parse(patch.get("registeredAt").toString()));
        if (patch.containsKey("tournamentId") && patch.get("tournamentId") != null) entity.setTournamentId(Long.valueOf(patch.get("tournamentId").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
        if (patch.containsKey("deckId") && patch.get("deckId") != null) entity.setDeckId(Long.valueOf(patch.get("deckId").toString()));
    }
    private void validate(TournamentRegistration entity) {
        if (entity.getFinalStanding() != null && !((entity.getFinalStanding() == null || entity.getFinalStanding() > 0))) throw new IllegalStateException("Final standing must be greater than zero");
        if (entity.getSeed() != null && !((entity.getSeed() == null || entity.getSeed() > 0))) throw new IllegalStateException("Seed must be greater than zero");
    }

    public void withdraw(Long id) {
        TournamentRegistration entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRegistration not found: " + id));
        entity.withdraw();
        repository.save(entity);
    }

    public void disqualify(Long id, String reason) {
        TournamentRegistration entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRegistration not found: " + id));
        entity.disqualify(reason);
        repository.save(entity);
    }

    public void promoteFromWaitlist(Long id) {
        TournamentRegistration entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentRegistration not found: " + id));
        entity.promoteFromWaitlist();
        repository.save(entity);
    }
}
