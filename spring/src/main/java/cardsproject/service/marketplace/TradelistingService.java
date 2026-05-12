package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Tradelisting;
import cardsproject.repository.marketplace.TradelistingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TradelistingService {

    private final TradelistingRepository repository;

    public TradelistingService(TradelistingRepository repository) {
        this.repository = repository;
    }

    public List<Tradelisting> findAll() {
        return repository.findAll();
    }

    public Optional<Tradelisting> findById(Long id) {
        return repository.findById(id);
    }

    public Tradelisting save(Tradelisting entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void close(Long id) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.close();
        repository.save(entity);
    }

    public void extend(Long id, Integer days) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.extend(days);
        repository.save(entity);
    }

    public void cancel(Long id) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.cancel();
        repository.save(entity);
    }
}
