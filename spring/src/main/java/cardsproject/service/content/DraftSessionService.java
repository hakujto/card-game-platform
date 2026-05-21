package cardsproject.service.content;

import cardsproject.domain.content.DraftSession;
import cardsproject.repository.content.DraftSessionRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.content.DraftSessionStatusType;
import cardsproject.domain.content.DraftSessionDraftTypeType;

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
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(DraftSession entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("status")) entity.setStatus(DraftSessionStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("draftType")) entity.setDraftType(DraftSessionDraftTypeType.valueOf(patch.get("draftType").toString()));
        if (patch.containsKey("seats") && patch.get("seats") != null) entity.setSeats(Integer.valueOf(patch.get("seats").toString()));
        if (patch.containsKey("timePerPickSeconds") && patch.get("timePerPickSeconds") != null) entity.setTimePerPickSeconds(Integer.valueOf(patch.get("timePerPickSeconds").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("completedAt") && patch.get("completedAt") != null) entity.setCompletedAt(java.time.LocalDateTime.parse(patch.get("completedAt").toString()));
        if (patch.containsKey("cardSetId") && patch.get("cardSetId") != null) entity.setCardSetId(Long.valueOf(patch.get("cardSetId").toString()));
    }
    private void validate(DraftSession entity) {
        if (entity.getCompletedAt() != null && !(DraftSessionStatusType.COMPLETED.equals(entity.getStatus()))) throw new IllegalStateException("completed_at can only be set when draft status is Completed");
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

    public Boolean isFull(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        Boolean result = entity.isFull();
        repository.save(entity);
        return result;
    }

    public DraftSession transitionWaitingForPlayersToDrafting(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.assertTransition(DraftSessionStatusType.DRAFTING);
        entity.setStatus(DraftSessionStatusType.DRAFTING);
        entity.start(); // @after
        return repository.save(entity);
    }

    public DraftSession transitionDraftingToCompleted(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.assertTransition(DraftSessionStatusType.COMPLETED);
        entity.setStatus(DraftSessionStatusType.COMPLETED);
        entity.complete(); // @after
        return repository.save(entity);
    }

    public DraftSession transitionDraftingToAbandoned(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.assertTransition(DraftSessionStatusType.ABANDONED);
        entity.setStatus(DraftSessionStatusType.ABANDONED);
        entity.abandon(); // @after
        return repository.save(entity);
    }

    public DraftSession transitionWaitingForPlayersToAbandoned(Long id) {
        DraftSession entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftSession not found: " + id));
        entity.assertTransition(DraftSessionStatusType.ABANDONED);
        entity.setStatus(DraftSessionStatusType.ABANDONED);
        entity.abandon(); // @after
        return repository.save(entity);
    }

    public void transitionCompletedToDrafting(Long id) {
        throw new IllegalStateException("Transition Completed -> Drafting is not allowed");
    }

    public void transitionAbandonedToDrafting(Long id) {
        throw new IllegalStateException("Transition Abandoned -> Drafting is not allowed");
    }
}
