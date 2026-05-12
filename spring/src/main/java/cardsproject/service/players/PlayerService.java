package cardsproject.service.players;

import cardsproject.domain.players.Player;
import cardsproject.repository.players.PlayerRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PlayerService {

    private final PlayerRepository repository;

    public PlayerService(PlayerRepository repository) {
        this.repository = repository;
    }

    public List<Player> findAll() {
        return repository.findAll();
    }

    public Optional<Player> findById(Long id) {
        return repository.findById(id);
    }

    public Player save(Player entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public Boolean promote(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        Boolean result = entity.promote();
        repository.save(entity);
        return result;
    }

    public Boolean demote(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        Boolean result = entity.demote();
        repository.save(entity);
        return result;
    }

    public void recordWin(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.recordWin();
        repository.save(entity);
    }

    public void recordLoss(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.recordLoss();
        repository.save(entity);
    }

    public java.math.BigDecimal winRate(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        java.math.BigDecimal result = entity.winRate();
        repository.save(entity);
        return result;
    }

    public void verify(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.verify();
        repository.save(entity);
    }

    public void updateRating(Long id, Integer delta) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.updateRating(delta);
        repository.save(entity);
    }
}
