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

    public void applyPatch(DeckCard entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("quantity") && patch.get("quantity") != null) entity.setQuantity(Integer.valueOf(patch.get("quantity").toString()));
        if (patch.containsKey("isCommander") && patch.get("isCommander") != null) entity.setIsCommander(Boolean.valueOf(patch.get("isCommander").toString()));
        if (patch.containsKey("deckId") && patch.get("deckId") != null) entity.setDeckId(Long.valueOf(patch.get("deckId").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
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
