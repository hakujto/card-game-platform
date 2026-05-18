package cardsproject.service.players;

import cardsproject.domain.players.Achievement;
import cardsproject.repository.players.AchievementRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AchievementService {

    private final AchievementRepository repository;

    public AchievementService(AchievementRepository repository) {
        this.repository = repository;
    }

    public List<Achievement> findAll() {
        return repository.findAll();
    }

    public Optional<Achievement> findById(Long id) {
        return repository.findById(id);
    }

    public Achievement save(Achievement entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public Integer pointValue(Long id, Integer multiplier) {
        Achievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Achievement not found: " + id));
        Integer result = entity.pointValue(multiplier);
        repository.save(entity);
        return result;
    }

    public void reveal(Long id) {
        Achievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Achievement not found: " + id));
        entity.reveal();
        repository.save(entity);
    }
}
