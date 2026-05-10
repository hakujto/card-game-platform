package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.CardPriceHistory;
import cardsproject.repository.marketplace.CardPriceHistoryRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardPriceHistoryService {

    private final CardPriceHistoryRepository repository;

    public CardPriceHistoryService(CardPriceHistoryRepository repository) {
        this.repository = repository;
    }

    public List<CardPriceHistory> findAll() {
        return repository.findAll();
    }

    public Optional<CardPriceHistory> findById(Long id) {
        return repository.findById(id);
    }

    public CardPriceHistory save(CardPriceHistory entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
