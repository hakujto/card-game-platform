package cardsproject.service.cards;

import cardsproject.domain.cards.CardAbility;
import cardsproject.repository.cards.CardAbilityRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.cards.CardAbilityAbilityTypeType;

@Service
public class CardAbilityService {

    private final CardAbilityRepository repository;

    public CardAbilityService(CardAbilityRepository repository) {
        this.repository = repository;
    }

    public List<CardAbility> findAll() {
        return repository.findAll();
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
