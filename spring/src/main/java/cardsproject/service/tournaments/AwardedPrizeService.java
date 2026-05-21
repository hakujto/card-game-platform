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

    public void applyPatch(AwardedPrize entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("finalPlacement") && patch.get("finalPlacement") != null) entity.setFinalPlacement(Integer.valueOf(patch.get("finalPlacement").toString()));
        if (patch.containsKey("awardedAt") && patch.get("awardedAt") != null) entity.setAwardedAt(java.time.LocalDateTime.parse(patch.get("awardedAt").toString()));
        if (patch.containsKey("claimed") && patch.get("claimed") != null) entity.setClaimed(Boolean.valueOf(patch.get("claimed").toString()));
        if (patch.containsKey("claimedAt") && patch.get("claimedAt") != null) entity.setClaimedAt(java.time.LocalDateTime.parse(patch.get("claimedAt").toString()));
        if (patch.containsKey("prizeId") && patch.get("prizeId") != null) entity.setPrizeId(Long.valueOf(patch.get("prizeId").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
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
