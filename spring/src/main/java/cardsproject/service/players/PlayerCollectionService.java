package cardsproject.service.players;

import cardsproject.domain.players.PlayerCollection;
import cardsproject.repository.players.PlayerCollectionRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.players.PlayerCollectionConditionType;
import cardsproject.domain.players.PlayerCollectionAcquiredViaType;

@Service
public class PlayerCollectionService {

    private final PlayerCollectionRepository repository;

    public PlayerCollectionService(PlayerCollectionRepository repository) {
        this.repository = repository;
    }

    public List<PlayerCollection> findAll() {
        return repository.findAll();
    }

    public Optional<PlayerCollection> findById(Long id) {
        return repository.findById(id);
    }

    public PlayerCollection save(PlayerCollection entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(PlayerCollection entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("quantity") && patch.get("quantity") != null) entity.setQuantity(Integer.valueOf(patch.get("quantity").toString()));
        if (patch.containsKey("foil") && patch.get("foil") != null) entity.setFoil(Boolean.valueOf(patch.get("foil").toString()));
        if (patch.containsKey("condition")) entity.setCondition(PlayerCollectionConditionType.valueOf(patch.get("condition").toString()));
        if (patch.containsKey("acquiredAt") && patch.get("acquiredAt") != null) entity.setAcquiredAt(java.time.LocalDateTime.parse(patch.get("acquiredAt").toString()));
        if (patch.containsKey("acquiredVia")) entity.setAcquiredVia(PlayerCollectionAcquiredViaType.valueOf(patch.get("acquiredVia").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
    }

    public void add(Long id, Integer quantity) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        entity.add(quantity);
        repository.save(entity);
    }

    public void remove(Long id, Integer quantity) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        entity.remove(quantity);
        repository.save(entity);
    }

    public java.math.BigDecimal estimatedValue(Long id) {
        PlayerCollection entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("PlayerCollection not found: " + id));
        java.math.BigDecimal result = entity.estimatedValue();
        repository.save(entity);
        return result;
    }
}
