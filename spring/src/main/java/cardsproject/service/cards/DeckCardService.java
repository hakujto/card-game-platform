package cardsproject.service.cards;

import cardsproject.domain.cards.DeckCard;
import cardsproject.repository.cards.DeckCardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.Objects;

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
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(DeckCard entity) {
        if (Boolean.TRUE.equals(entity.getIsCommander()) && !(Objects.equals(entity.getQuantity(), 1))) throw new IllegalStateException("Commander card must appear exactly once in the deck");
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
