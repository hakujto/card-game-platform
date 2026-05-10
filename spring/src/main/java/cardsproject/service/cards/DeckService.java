package cardsproject.service.cards;

import cardsproject.domain.cards.Deck;
import cardsproject.repository.cards.DeckRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DeckService {

    private final DeckRepository repository;

    public DeckService(DeckRepository repository) {
        this.repository = repository;
    }

    public List<Deck> findAll() {
        return repository.findAll();
    }

    public Optional<Deck> findById(Long id) {
        return repository.findById(id);
    }

    public Deck save(Deck entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
