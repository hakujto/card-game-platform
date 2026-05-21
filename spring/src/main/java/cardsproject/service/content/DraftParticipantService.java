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

    public void applyPatch(DraftParticipant entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("seatNumber") && patch.get("seatNumber") != null) entity.setSeatNumber(Integer.valueOf(patch.get("seatNumber").toString()));
        if (patch.containsKey("joinedAt") && patch.get("joinedAt") != null) entity.setJoinedAt(java.time.LocalDateTime.parse(patch.get("joinedAt").toString()));
        if (patch.containsKey("sessionId") && patch.get("sessionId") != null) entity.setSessionId(Long.valueOf(patch.get("sessionId").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
    }

    public void pickCard(Long id, Integer cardId, Integer packNumber) {
        DraftParticipant entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftParticipant not found: " + id));
        entity.pickCard(cardId, packNumber);
        repository.save(entity);
    }

    public Integer draftedCardCount(Long id) {
        DraftParticipant entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("DraftParticipant not found: " + id));
        Integer result = entity.draftedCardCount();
        repository.save(entity);
        return result;
    }
}
