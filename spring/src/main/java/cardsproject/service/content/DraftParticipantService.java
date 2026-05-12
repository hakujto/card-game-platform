package cardsproject.service.content;

import cardsproject.domain.content.DraftParticipant;
import cardsproject.repository.content.DraftParticipantRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DraftParticipantService {

    private final DraftParticipantRepository repository;

    public DraftParticipantService(DraftParticipantRepository repository) {
        this.repository = repository;
    }

    public List<DraftParticipant> findAll() {
        return repository.findAll();
    }

    public Optional<DraftParticipant> findById(Long id) {
        return repository.findById(id);
    }

    public DraftParticipant save(DraftParticipant entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void pickCard(Long id, Integer cardId, Integer packNumber) {
        DraftParticipant entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftParticipant not found: " + id));
        entity.pickCard(cardId, packNumber);
        repository.save(entity);
    }
}
