package cardsproject.service.content;

import cardsproject.domain.content.DraftPick;
import cardsproject.repository.content.DraftPickRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DraftPickService {

    private final DraftPickRepository repository;

    public DraftPickService(DraftPickRepository repository) {
        this.repository = repository;
    }

    public List<DraftPick> findAll() {
        return repository.findAll();
    }

    public Optional<DraftPick> findById(Long id) {
        return repository.findById(id);
    }

    public DraftPick save(DraftPick entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public Boolean isFirstPick(Long id) {
        DraftPick entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftPick not found: " + id));
        Boolean result = entity.isFirstPick();
        repository.save(entity);
        return result;
    }
}
