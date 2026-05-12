package cardsproject.service.content;

import cardsproject.domain.content.DraftSession;
import cardsproject.repository.content.DraftSessionRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DraftSessionService {

    private final DraftSessionRepository repository;

    public DraftSessionService(DraftSessionRepository repository) {
        this.repository = repository;
    }

    public List<DraftSession> findAll() {
        return repository.findAll();
    }

    public Optional<DraftSession> findById(Long id) {
        return repository.findById(id);
    }

    public DraftSession save(DraftSession entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void start(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.start();
        repository.save(entity);
    }

    public void abandon(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.abandon();
        repository.save(entity);
    }

    public void complete(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.complete();
        repository.save(entity);
    }
}
