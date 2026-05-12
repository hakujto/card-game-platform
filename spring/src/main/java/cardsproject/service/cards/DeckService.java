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

    public Boolean validateSize(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Boolean result = entity.validateSize();
        repository.save(entity);
        return result;
    }

    public Deck clone(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Deck result = entity.clone();
        repository.save(entity);
        return result;
    }

    public void publish(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.publish();
        repository.save(entity);
    }

    public void unpublish(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.unpublish();
        repository.save(entity);
    }

    public Boolean certifyTournamentLegal(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Boolean result = entity.certifyTournamentLegal();
        repository.save(entity);
        return result;
    }
}
