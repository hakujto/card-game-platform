package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Tournament;
import cardsproject.repository.tournaments.TournamentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentStatusType;

@Service
public class TournamentService {

    private final TournamentRepository repository;

    public TournamentService(TournamentRepository repository) {
        this.repository = repository;
    }

    public List<Tournament> findAll() {
        return repository.findAll();
    }

    public Optional<Tournament> findById(Long id) {
        return repository.findById(id);
    }

    public Tournament save(Tournament entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Tournament entity) {
        if (entity.getEndTime() != null && !((entity.getEndTime() == null || (entity.getStartTime() != null && entity.getEndTime().isAfter(entity.getStartTime()))))) throw new IllegalStateException("End time must be after start time");
    }

    public void start(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.start();
        repository.save(entity);
    }

    public void cancel(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.cancel();
        repository.save(entity);
    }

    public void complete(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.complete();
        repository.save(entity);
    }

    public void generateRound(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.generateRound();
        repository.save(entity);
    }

    public java.math.BigDecimal calculatePrizeDistribution(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        java.math.BigDecimal result = entity.calculatePrizeDistribution();
        repository.save(entity);
        return result;
    }

    public void registerPlayer(Long id, Integer playerId, Integer deckId) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.registerPlayer(playerId, deckId);
        repository.save(entity);
    }

    public Boolean isFull(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        Boolean result = entity.isFull();
        repository.save(entity);
        return result;
    }

    public Tournament transitionDraftToRegistration(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.REGISTRATION);
        if (entity.getName() == null) {
            throw new IllegalArgumentException("name is required for Draft -> Registration");
        }
        if (entity.getStartTime() == null) {
            throw new IllegalArgumentException("start_time is required for Draft -> Registration");
        }
        entity.setStatus(TournamentStatusType.REGISTRATION);
        return repository.save(entity);
    }

    public Tournament transitionRegistrationToOngoing(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.ONGOING);
        entity.setStatus(TournamentStatusType.ONGOING);
        entity.start(); // @after
        return repository.save(entity);
    }

    public Tournament transitionRegistrationToCancelled(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.CANCELLED);
        entity.setStatus(TournamentStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public Tournament transitionOngoingToCompleted(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.COMPLETED);
        entity.setStatus(TournamentStatusType.COMPLETED);
        entity.complete(); // @after
        entity.calculatePrizeDistribution(); // @after
        return repository.save(entity);
    }

    public Tournament transitionOngoingToCancelled(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.CANCELLED);
        entity.setStatus(TournamentStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public void transitionCompletedToDraft(Long id) {
        throw new IllegalStateException("Transition Completed -> Draft is not allowed");
    }

    public void transitionCancelledToDraft(Long id) {
        throw new IllegalStateException("Transition Cancelled -> Draft is not allowed");
    }
}
