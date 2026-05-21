package cardsproject.service.players;

import cardsproject.domain.players.PlayerAchievement;
import cardsproject.repository.players.PlayerAchievementRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PlayerAchievementService {

    private final PlayerAchievementRepository repository;

    public PlayerAchievementService(PlayerAchievementRepository repository) {
        this.repository = repository;
    }

    public List<PlayerAchievement> findAll() {
        return repository.findAll();
    }

    public Optional<PlayerAchievement> findById(Long id) {
        return repository.findById(id);
    }

    public PlayerAchievement save(PlayerAchievement entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(PlayerAchievement entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("earnedAt") && patch.get("earnedAt") != null) entity.setEarnedAt(java.time.LocalDateTime.parse(patch.get("earnedAt").toString()));
        if (patch.containsKey("progress") && patch.get("progress") != null) entity.setProgress(Integer.valueOf(patch.get("progress").toString()));
        if (patch.containsKey("isCompleted") && patch.get("isCompleted") != null) entity.setIsCompleted(Boolean.valueOf(patch.get("isCompleted").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
        if (patch.containsKey("achievementId") && patch.get("achievementId") != null) entity.setAchievementId(Long.valueOf(patch.get("achievementId").toString()));
    }
    private void validate(PlayerAchievement entity) {
        if (Boolean.TRUE.equals(entity.getIsCompleted()) && !((entity.getProgress() == null || entity.getProgress() > 0))) throw new IllegalStateException("Completed achievement must have progress greater than zero");
    }

    public void incrementProgress(Long id, Integer amount) {
        PlayerAchievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerAchievement not found: " + id));
        entity.incrementProgress(amount);
        repository.save(entity);
    }

    public void complete(Long id) {
        PlayerAchievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerAchievement not found: " + id));
        entity.complete();
        repository.save(entity);
    }

    // triggered by @on(is_completed = true)
    public void setIsCompleted(Long id, boolean isCompleted) {
        PlayerAchievement entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerAchievement not found: " + id));
        entity.setIsCompleted(isCompleted);
        if (isCompleted) {
            entity.complete();
        }
        repository.save(entity);
    }
}
