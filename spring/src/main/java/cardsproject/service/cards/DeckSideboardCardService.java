package cardsproject.service.cards;

import cardsproject.domain.cards.DeckSideboardCard;
import cardsproject.repository.cards.DeckSideboardCardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DeckSideboardCardService {

    private final DeckSideboardCardRepository repository;

    public DeckSideboardCardService(DeckSideboardCardRepository repository) {
        this.repository = repository;
    }

    public List<DeckSideboardCard> findAll() {
        return repository.findAll();
    }

    public Optional<DeckSideboardCard> findById(Long id) {
        return repository.findById(id);
    }

    public DeckSideboardCard save(DeckSideboardCard entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
