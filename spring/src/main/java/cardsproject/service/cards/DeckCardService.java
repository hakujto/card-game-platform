package cardsproject.service.cards;

import cardsproject.domain.cards.DeckCard;
import cardsproject.repository.cards.DeckCardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DeckCardService {

    private final DeckCardRepository repository;

    public DeckCardService(DeckCardRepository repository) {
        this.repository = repository;
    }

    public List<DeckCard> findAll() {
        return repository.findAll();
    }

    public Optional<DeckCard> findById(Long id) {
        return repository.findById(id);
    }

    public DeckCard save(DeckCard entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void increment(Long id, Integer amount) {
        DeckCard entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DeckCard not found: " + id));
        entity.increment(amount);
        repository.save(entity);
    }

    public void decrement(Long id, Integer amount) {
        DeckCard entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DeckCard not found: " + id));
        entity.decrement(amount);
        repository.save(entity);
    }
}
