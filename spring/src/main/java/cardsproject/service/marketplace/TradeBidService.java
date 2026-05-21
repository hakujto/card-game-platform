package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.TradeBid;
import cardsproject.repository.marketplace.TradeBidRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TradeBidService {

    private final TradeBidRepository repository;

    public TradeBidService(TradeBidRepository repository) {
        this.repository = repository;
    }

    public List<TradeBid> findAll() {
        return repository.findAll();
    }

    public Optional<TradeBid> findById(Long id) {
        return repository.findById(id);
    }

    public TradeBid save(TradeBid entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(TradeBid entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("amount") && patch.get("amount") != null) entity.setAmount(new java.math.BigDecimal(patch.get("amount").toString()));
        if (patch.containsKey("placedAt") && patch.get("placedAt") != null) entity.setPlacedAt(java.time.LocalDateTime.parse(patch.get("placedAt").toString()));
        if (patch.containsKey("isWinning") && patch.get("isWinning") != null) entity.setIsWinning(Boolean.valueOf(patch.get("isWinning").toString()));
        if (patch.containsKey("listingId") && patch.get("listingId") != null) entity.setListingId(Long.valueOf(patch.get("listingId").toString()));
        if (patch.containsKey("bidderId") && patch.get("bidderId") != null) entity.setBidderId(Long.valueOf(patch.get("bidderId").toString()));
    }

    public Boolean outbidBy(Long id, java.math.BigDecimal newAmount) {
        TradeBid entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeBid not found: " + id));
        Boolean result = entity.outbidBy(newAmount);
        repository.save(entity);
        return result;
    }

    public void retract(Long id) {
        TradeBid entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeBid not found: " + id));
        entity.retract();
        repository.save(entity);
    }
}
