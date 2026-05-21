package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Season;
import cardsproject.repository.tournaments.SeasonRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.SeasonFormatType;

@Service
public class SeasonService {

    private final SeasonRepository repository;

    public SeasonService(SeasonRepository repository) {
        this.repository = repository;
    }

    public List<Season> findAll() {
        return repository.findAll();
    }

    public List<Season> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Season> findById(Long id) {
        return repository.findById(id);
    }

    public Season save(Season entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Season entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("startDate") && patch.get("startDate") != null) entity.setStartDate(java.time.LocalDate.parse(patch.get("startDate").toString()));
        if (patch.containsKey("endDate") && patch.get("endDate") != null) entity.setEndDate(java.time.LocalDate.parse(patch.get("endDate").toString()));
        if (patch.containsKey("format")) entity.setFormat(SeasonFormatType.valueOf(patch.get("format").toString()));
        if (patch.containsKey("isActive") && patch.get("isActive") != null) entity.setIsActive(Boolean.valueOf(patch.get("isActive").toString()));
        if (patch.containsKey("rewardDescription") && patch.get("rewardDescription") != null) entity.setRewardDescription(patch.get("rewardDescription").toString());
    }

    public void activate(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.activate();
        repository.save(entity);
    }

    public void deactivate(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.deactivate();
        repository.save(entity);
    }

    public void finalizeRewards(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        entity.finalizeRewards();
        repository.save(entity);
    }

    public Boolean isOngoing(Long id) {
        Season entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Season not found: " + id));
        Boolean result = entity.isOngoing();
        repository.save(entity);
        return result;
    }
}
