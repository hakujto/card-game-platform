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
}
