package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Tournament;
import cardsproject.repository.tournaments.TournamentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
}
