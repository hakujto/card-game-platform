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

    public void add(Long id, Integer quantity) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        entity.add(quantity);
        repository.save(entity);
    }

    public void remove(Long id, Integer quantity) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        entity.remove(quantity);
        repository.save(entity);
    }

    public java.math.BigDecimal estimatedValue(Long id) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        java.math.BigDecimal result = entity.estimatedValue();
        repository.save(entity);
        return result;
    }
}
