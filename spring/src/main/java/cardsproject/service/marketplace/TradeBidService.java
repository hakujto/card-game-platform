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
