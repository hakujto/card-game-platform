package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentRound;
import cardsproject.repository.tournaments.TournamentRoundRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
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
}
