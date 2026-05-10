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
}
