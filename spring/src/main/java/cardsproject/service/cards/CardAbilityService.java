package cardsproject.service.cards;

import cardsproject.domain.cards.CardAbility;
import cardsproject.repository.cards.CardAbilityRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.cards.CardAbilityAbilityTypeType;
import cardsproject.domain.cards.CardAbilityTimingType;

@Service
public class CardAbilityService {

    private final CardAbilityRepository repository;

    public CardAbilityService(CardAbilityRepository repository) {
        this.repository = repository;
    }

    public List<CardAbility> findAll() {
        return repository.findAll();
    }

    public List<CardAbility> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getKeyword() != null && e.getKeyword().toLowerCase().contains(q.toLowerCase())) || (e.getAbilityText() != null && e.getAbilityText().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<CardAbility> findById(Long id) {
        return repository.findById(id);
    }

    public CardAbility save(CardAbility entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(CardAbility entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("abilityType")) entity.setAbilityType(CardAbilityAbilityTypeType.valueOf(patch.get("abilityType").toString()));
        if (patch.containsKey("keyword") && patch.get("keyword") != null) entity.setKeyword(patch.get("keyword").toString());
        if (patch.containsKey("abilityText") && patch.get("abilityText") != null) entity.setAbilityText(patch.get("abilityText").toString());
        if (patch.containsKey("timing")) entity.setTiming(CardAbilityTimingType.valueOf(patch.get("timing").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
    }
    private void validate(CardAbility entity) {
        if (CardAbilityAbilityTypeType.KEYWORD.equals(entity.getAbilityType()) && entity.getKeyword() == null) throw new IllegalStateException("Keyword ability must have a keyword name");
    }

    public Boolean isUsableAt(Long id, String timing) {
        CardAbility entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardAbility not found: " + id));
        Boolean result = entity.isUsableAt(timing);
        repository.save(entity);
        return result;
    }

    public String describe(Long id) {
        CardAbility entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardAbility not found: " + id));
        String result = entity.describe();
        repository.save(entity);
        return result;
    }
}
