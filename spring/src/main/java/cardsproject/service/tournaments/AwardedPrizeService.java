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
}
