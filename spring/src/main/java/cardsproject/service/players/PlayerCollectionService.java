package cardsproject.service.players;

import cardsproject.domain.players.PlayerCollection;
import cardsproject.repository.players.PlayerCollectionRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PlayerCollectionService {

    private final PlayerCollectionRepository repository;

    public PlayerCollectionService(PlayerCollectionRepository repository) {
        this.repository = repository;
    }

    public List<PlayerCollection> findAll() {
        return repository.findAll();
    }

    public Optional<PlayerCollection> findById(Long id) {
        return repository.findById(id);
    }

    public PlayerCollection save(PlayerCollection entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
