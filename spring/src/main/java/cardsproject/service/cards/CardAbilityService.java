package cardsproject.service.cards;

import cardsproject.domain.cards.CardAbility;
import cardsproject.repository.cards.CardAbilityRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
