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
}
