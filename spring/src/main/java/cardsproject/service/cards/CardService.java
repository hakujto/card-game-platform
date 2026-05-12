package cardsproject.service.cards;

import cardsproject.domain.cards.Card;
import cardsproject.repository.cards.CardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardService {

    private final CardRepository repository;

    public CardService(CardRepository repository) {
        this.repository = repository;
    }

    public List<Card> findAll() {
        return repository.findAll();
    }

    public Optional<Card> findById(Long id) {
        return repository.findById(id);
    }

    public Card save(Card entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void ban(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.ban();
        repository.save(entity);
    }

    public void unban(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.unban();
        repository.save(entity);
    }

    public void restrict(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.restrict();
        repository.save(entity);
    }

    public void unrestrict(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.unrestrict();
        repository.save(entity);
    }

    public java.math.BigDecimal calculateValue(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        java.math.BigDecimal result = entity.calculateValue();
        repository.save(entity);
        return result;
    }
}
