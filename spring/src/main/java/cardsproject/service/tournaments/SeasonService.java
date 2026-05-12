package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Season;
import cardsproject.repository.tournaments.SeasonRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class SeasonService {

    private final SeasonRepository repository;

    public SeasonService(SeasonRepository repository) {
        this.repository = repository;
    }

    public List<Season> findAll() {
        return repository.findAll();
    }

    public Optional<Season> findById(Long id) {
        return repository.findById(id);
    }

    public Season save(Season entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void activate(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.activate();
        repository.save(entity);
    }

    public void deactivate(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.deactivate();
        repository.save(entity);
    }

    public void finalizeRewards(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.finalizeRewards();
        repository.save(entity);
    }
}
