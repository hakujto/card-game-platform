package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.TradeTransaction;
import cardsproject.repository.marketplace.TradeTransactionRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.TradeTransactionStatusType;

@Service
public class TradeTransactionService {

    private final TradeTransactionRepository repository;

    public TradeTransactionService(TradeTransactionRepository repository) {
        this.repository = repository;
    }

    public List<TradeTransaction> findAll() {
        return repository.findAll();
    }

    public Optional<TradeTransaction> findById(Long id) {
        return repository.findById(id);
    }

    public TradeTransaction save(TradeTransaction entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(TradeTransaction entity) {
        if (TradeTransactionStatusType.COMPLETED.equals(entity.getStatus()) && entity.getCompletedAt() == null) throw new IllegalStateException("Completed transaction must have a completed_at timestamp");
    }

    public void complete(Long id) {
        TradeTransaction entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeTransaction not found: " + id));
        entity.complete();
        repository.save(entity);
    }

    public void refund(Long id) {
        TradeTransaction entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeTransaction not found: " + id));
        entity.refund();
        repository.save(entity);
    }

    public void openDispute(Long id, String reason) {
        TradeTransaction entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeTransaction not found: " + id));
        entity.openDispute(reason);
        repository.save(entity);
    }

    public java.math.BigDecimal sellerNet(Long id) {
        TradeTransaction entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeTransaction not found: " + id));
        java.math.BigDecimal result = entity.sellerNet();
        repository.save(entity);
        return result;
    }
}
