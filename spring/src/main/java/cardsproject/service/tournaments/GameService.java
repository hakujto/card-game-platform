package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Game;
import cardsproject.repository.tournaments.GameRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class GameService {

    private final GameRepository repository;

    public GameService(GameRepository repository) {
        this.repository = repository;
    }

    public List<Game> findAll() {
        return repository.findAll();
    }

    public Optional<Game> findById(Long id) {
        return repository.findById(id);
    }

    public Game save(Game entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void recordWinner(Long id, String winnerSide) {
        Game entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Game not found: " + id));
        entity.recordWinner(winnerSide);
        repository.save(entity);
    }
}
