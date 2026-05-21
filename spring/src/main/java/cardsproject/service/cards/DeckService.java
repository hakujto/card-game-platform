package cardsproject.service.cards;

import cardsproject.domain.cards.Deck;
import cardsproject.repository.cards.DeckRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.cards.DeckFormatType;
import cardsproject.domain.cards.DeckArchetypeType;

@Service
public class DeckService {

    private final DeckRepository repository;

    public DeckService(DeckRepository repository) {
        this.repository = repository;
    }

    public List<Deck> findAll() {
        return repository.findAll();
    }

    public List<Deck> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getDescription() != null && e.getDescription().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Deck> findById(Long id) {
        return repository.findById(id);
    }

    public Deck save(Deck entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Deck entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("format")) entity.setFormat(DeckFormatType.valueOf(patch.get("format").toString()));
        if (patch.containsKey("isPublic") && patch.get("isPublic") != null) entity.setIsPublic(Boolean.valueOf(patch.get("isPublic").toString()));
        if (patch.containsKey("isTournamentLegal") && patch.get("isTournamentLegal") != null) entity.setIsTournamentLegal(Boolean.valueOf(patch.get("isTournamentLegal").toString()));
        if (patch.containsKey("archetype")) entity.setArchetype(DeckArchetypeType.valueOf(patch.get("archetype").toString()));
        if (patch.containsKey("wins") && patch.get("wins") != null) entity.setWins(Integer.valueOf(patch.get("wins").toString()));
        if (patch.containsKey("losses") && patch.get("losses") != null) entity.setLosses(Integer.valueOf(patch.get("losses").toString()));
        if (patch.containsKey("draws") && patch.get("draws") != null) entity.setDraws(Integer.valueOf(patch.get("draws").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("updatedAt") && patch.get("updatedAt") != null) entity.setUpdatedAt(java.time.LocalDateTime.parse(patch.get("updatedAt").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
    }
    private void validate(Deck entity) {
        if (Boolean.TRUE.equals(entity.getIsTournamentLegal()) && !(Boolean.TRUE.equals(entity.getIsPublic()))) throw new IllegalStateException("Tournament-legal deck must be made public");
    }

    public Boolean validateSize(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Boolean result = entity.validateSize();
        repository.save(entity);
        return result;
    }

    public void addCard(Long id, Integer cardId, Integer quantity) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.addCard(cardId, quantity);
        repository.save(entity);
    }

    public void removeCard(Long id, Long cardId) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.removeCard(cardId.intValue());
        repository.save(entity);
    }

    public java.math.BigDecimal winRate(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        java.math.BigDecimal result = entity.winRate();
        repository.save(entity);
        return result;
    }

    public Deck clone(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Deck result = entity.clone();
        repository.save(entity);
        return result;
    }

    public void publish(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.publish();
        repository.save(entity);
    }

    public void unpublish(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        entity.unpublish();
        repository.save(entity);
    }

    public Boolean certifyTournamentLegal(Long id) {
        Deck entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Deck not found: " + id));
        Boolean result = entity.certifyTournamentLegal();
        repository.save(entity);
        return result;
    }
}
