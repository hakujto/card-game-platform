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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
