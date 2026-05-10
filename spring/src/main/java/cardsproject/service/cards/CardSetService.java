package cardsproject.service.cards;

import cardsproject.domain.cards.CardSet;
import cardsproject.repository.cards.CardSetRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardSetService {

    private final CardSetRepository repository;

    public CardSetService(CardSetRepository repository) {
        this.repository = repository;
    }

    public List<CardSet> findAll() {
        return repository.findAll();
    }

    public Optional<CardSet> findById(Long id) {
        return repository.findById(id);
    }

    public CardSet save(CardSet entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
