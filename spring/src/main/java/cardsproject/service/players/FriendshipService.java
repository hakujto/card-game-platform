package cardsproject.service.players;

import cardsproject.domain.players.Friendship;
import cardsproject.repository.players.FriendshipRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.players.FriendshipStatusType;

@Service
public class FriendshipService {

    private final FriendshipRepository repository;

    public FriendshipService(FriendshipRepository repository) {
        this.repository = repository;
    }

    public List<Friendship> findAll() {
        return repository.findAll();
    }

    public Optional<Friendship> findById(Long id) {
        return repository.findById(id);
    }

    public Friendship save(Friendship entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Friendship entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("status")) entity.setStatus(FriendshipStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("requesterId") && patch.get("requesterId") != null) entity.setRequesterId(Long.valueOf(patch.get("requesterId").toString()));
        if (patch.containsKey("receiverId") && patch.get("receiverId") != null) entity.setReceiverId(Long.valueOf(patch.get("receiverId").toString()));
    }

    public void accept(Long id) {
        Friendship entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Friendship not found: " + id));
        entity.accept();
        repository.save(entity);
    }

    public void decline(Long id) {
        Friendship entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Friendship not found: " + id));
        entity.decline();
        repository.save(entity);
    }

    public void block(Long id) {
        Friendship entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Friendship not found: " + id));
        entity.block();
        repository.save(entity);
    }
}
