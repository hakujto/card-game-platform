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

    public java.math.BigDecimal priceChangePercent(Long id, java.math.BigDecimal previousAvg) {
        CardPriceHistory entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardPriceHistory not found: " + id));
        java.math.BigDecimal result = entity.priceChangePercent(previousAvg);
        repository.save(entity);
        return result;
    }

    public Boolean isPriceSpike(Long id, Integer thresholdPercent) {
        CardPriceHistory entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardPriceHistory not found: " + id));
        Boolean result = entity.isPriceSpike(thresholdPercent);
        repository.save(entity);
        return result;
    }
}
