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

    public void applyPatch(DraftPick entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("pickNumber") && patch.get("pickNumber") != null) entity.setPickNumber(Integer.valueOf(patch.get("pickNumber").toString()));
        if (patch.containsKey("packNumber") && patch.get("packNumber") != null) entity.setPackNumber(Integer.valueOf(patch.get("packNumber").toString()));
        if (patch.containsKey("pickedAt") && patch.get("pickedAt") != null) entity.setPickedAt(java.time.LocalDateTime.parse(patch.get("pickedAt").toString()));
        if (patch.containsKey("participantId") && patch.get("participantId") != null) entity.setParticipantId(Long.valueOf(patch.get("participantId").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
    }

    public Boolean isFirstPick(Long id) {
        DraftPick entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftPick not found: " + id));
        Boolean result = entity.isFirstPick();
        repository.save(entity);
        return result;
    }
}
