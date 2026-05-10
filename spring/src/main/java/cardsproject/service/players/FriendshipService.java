package cardsproject.service.players;

import cardsproject.domain.players.Friendship;
import cardsproject.repository.players.FriendshipRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
}
