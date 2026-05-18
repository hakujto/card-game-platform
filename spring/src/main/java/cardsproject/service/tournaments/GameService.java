package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Game;
import cardsproject.repository.tournaments.GameRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.GameWinnerSideType;

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
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Game entity) {
        if (entity.getTurnsPlayed() != null && !((entity.getTurnsPlayed() == null || entity.getTurnsPlayed() > 0))) throw new IllegalStateException("Turns played must be greater than zero");
        if (entity.getDurationSeconds() != null && !((entity.getDurationSeconds() == null || entity.getDurationSeconds() > 0))) throw new IllegalStateException("Game duration must be greater than zero");
        if (GameWinnerSideType.DRAW.equals(entity.getWinnerSide()) && entity.getWinnerId() != null) throw new IllegalStateException("A draw cannot have a winner");
        if ((entity.getWinnerSide() != null && !GameWinnerSideType.DRAW.equals(entity.getWinnerSide())) && entity.getWinnerId() == null) throw new IllegalStateException("A decisive game must have a winner player set");
    }

    public void recordWinner(Long id, String winnerSide) {
        Game entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Game not found: " + id));
        entity.recordWinner(winnerSide);
        repository.save(entity);
    }

    public java.math.BigDecimal durationMinutes(Long id) {
        Game entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Game not found: " + id));
        java.math.BigDecimal result = entity.durationMinutes();
        repository.save(entity);
        return result;
    }
}
