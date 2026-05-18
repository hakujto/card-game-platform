package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.AwardedPrize;
import cardsproject.repository.tournaments.AwardedPrizeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AwardedPrizeService {

    private final AwardedPrizeRepository repository;

    public AwardedPrizeService(AwardedPrizeRepository repository) {
        this.repository = repository;
    }

    public List<AwardedPrize> findAll() {
        return repository.findAll();
    }

    public Optional<AwardedPrize> findById(Long id) {
        return repository.findById(id);
    }

    public AwardedPrize save(AwardedPrize entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(AwardedPrize entity) {
        if (Boolean.TRUE.equals(entity.getClaimed()) && entity.getClaimedAt() == null) throw new IllegalStateException("Claimed prize must have a claimed_at timestamp");
    }

    public void claim(Long id) {
        AwardedPrize entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("AwardedPrize not found: " + id));
        entity.claim();
        repository.save(entity);
    }

    // triggered by @on(claimed = true)
    public void setClaimed(Long id, boolean claimed) {
        AwardedPrize entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("AwardedPrize not found: " + id));
        entity.setClaimed(claimed);
        if (claimed) {
            entity.claim();
        }
        repository.save(entity);
    }
}
