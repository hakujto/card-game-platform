package cardsproject.service.players;

import cardsproject.domain.players.Achievement;
import cardsproject.repository.players.AchievementRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.players.AchievementRarityType;

@Service
public class AchievementService {

    private final AchievementRepository repository;

    public AchievementService(AchievementRepository repository) {
        this.repository = repository;
    }

    public List<Achievement> findAll() {
        return repository.findAll();
    }

    public List<Achievement> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getDescription() != null && e.getDescription().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Achievement> findById(Long id) {
        return repository.findById(id);
    }

    public Achievement save(Achievement entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Achievement entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("iconUrl") && patch.get("iconUrl") != null) entity.setIconUrl(patch.get("iconUrl").toString());
        if (patch.containsKey("points") && patch.get("points") != null) entity.setPoints(Integer.valueOf(patch.get("points").toString()));
        if (patch.containsKey("rarity")) entity.setRarity(AchievementRarityType.valueOf(patch.get("rarity").toString()));
        if (patch.containsKey("isHidden") && patch.get("isHidden") != null) entity.setIsHidden(Boolean.valueOf(patch.get("isHidden").toString()));
    }

    public Integer pointValue(Long id, Integer multiplier) {
        Achievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Achievement not found: " + id));
        Integer result = entity.pointValue(multiplier);
        repository.save(entity);
        return result;
    }

    public void reveal(Long id) {
        Achievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Achievement not found: " + id));
        entity.reveal();
        repository.save(entity);
    }
}
