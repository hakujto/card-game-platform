package cardsproject.service.cards;

import cardsproject.domain.cards.DeckTagAssignment;
import cardsproject.repository.cards.DeckTagAssignmentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DeckTagAssignmentService {

    private final DeckTagAssignmentRepository repository;

    public DeckTagAssignmentService(DeckTagAssignmentRepository repository) {
        this.repository = repository;
    }

    public List<DeckTagAssignment> findAll() {
        return repository.findAll();
    }

    public Optional<DeckTagAssignment> findById(Long id) {
        return repository.findById(id);
    }

    public DeckTagAssignment save(DeckTagAssignment entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(DeckTagAssignment entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("deckId") && patch.get("deckId") != null) entity.setDeckId(Long.valueOf(patch.get("deckId").toString()));
        if (patch.containsKey("tagId") && patch.get("tagId") != null) entity.setTagId(Long.valueOf(patch.get("tagId").toString()));
    }
}
