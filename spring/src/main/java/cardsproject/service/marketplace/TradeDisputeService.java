package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.TradeDispute;
import cardsproject.repository.marketplace.TradeDisputeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.TradeDisputeStatusType;

@Service
public class TradeDisputeService {

    private final TradeDisputeRepository repository;

    public TradeDisputeService(TradeDisputeRepository repository) {
        this.repository = repository;
    }

    public List<TradeDispute> findAll() {
        return repository.findAll();
    }

    public Optional<TradeDispute> findById(Long id) {
        return repository.findById(id);
    }

    public TradeDispute save(TradeDispute entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(TradeDispute entity) {
        if (entity.getResolvedAt() != null && !(TradeDisputeStatusType.RESOLVED.equals(entity.getStatus()))) throw new IllegalStateException("resolved_at_requires_terminal_status");
    }

    public void escalate(Long id) {
        TradeDispute entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeDispute not found: " + id));
        entity.escalate();
        repository.save(entity);
    }

    public void resolve(Long id, String resolutionText) {
        TradeDispute entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeDispute not found: " + id));
        entity.resolve(resolutionText);
        repository.save(entity);
    }

    public void review(Long id) {
        TradeDispute entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeDispute not found: " + id));
        entity.review();
        repository.save(entity);
    }
}
