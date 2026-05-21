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

    public void applyPatch(CardPriceHistory entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("priceDate") && patch.get("priceDate") != null) entity.setPriceDate(java.time.LocalDate.parse(patch.get("priceDate").toString()));
        if (patch.containsKey("avgPrice") && patch.get("avgPrice") != null) entity.setAvgPrice(new java.math.BigDecimal(patch.get("avgPrice").toString()));
        if (patch.containsKey("minPrice") && patch.get("minPrice") != null) entity.setMinPrice(new java.math.BigDecimal(patch.get("minPrice").toString()));
        if (patch.containsKey("maxPrice") && patch.get("maxPrice") != null) entity.setMaxPrice(new java.math.BigDecimal(patch.get("maxPrice").toString()));
        if (patch.containsKey("volume") && patch.get("volume") != null) entity.setVolume(Integer.valueOf(patch.get("volume").toString()));
        if (patch.containsKey("foil") && patch.get("foil") != null) entity.setFoil(Boolean.valueOf(patch.get("foil").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
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
