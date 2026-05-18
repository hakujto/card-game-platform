package cardsproject.service.cards;

import cardsproject.domain.cards.DeckTag;
import cardsproject.repository.cards.DeckTagRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DeckTagService {

    private final DeckTagRepository repository;

    public DeckTagService(DeckTagRepository repository) {
        this.repository = repository;
    }

    public List<DeckTag> findAll() {
        return repository.findAll();
    }

    public Optional<DeckTag> findById(Long id) {
        return repository.findById(id);
    }

    public DeckTag save(DeckTag entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void rename(Long id, String newName) {
        DeckTag entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DeckTag not found: " + id));
        entity.rename(newName);
        repository.save(entity);
    }

    public void mergeInto(Long id, Integer targetTagId) {
        DeckTag entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DeckTag not found: " + id));
        entity.mergeInto(targetTagId);
        repository.save(entity);
    }
}
