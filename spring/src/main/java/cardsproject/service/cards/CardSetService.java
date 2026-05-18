package cardsproject.service.cards;

import cardsproject.domain.cards.CardSet;
import cardsproject.repository.cards.CardSetRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardSetService {

    private final CardSetRepository repository;

    public CardSetService(CardSetRepository repository) {
        this.repository = repository;
    }

    public List<CardSet> findAll() {
        return repository.findAll();
    }

    public Optional<CardSet> findById(Long id) {
        return repository.findById(id);
    }

    public CardSet save(CardSet entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(CardSet entity) {
        if (entity.getRotationDate() != null && !((entity.getRotationDate() == null || (entity.getReleaseDate() != null && entity.getRotationDate().isAfter(entity.getReleaseDate()))))) throw new IllegalStateException("Rotation date must be after release date");
        if (Boolean.TRUE.equals(entity.getIsRotated()) && entity.getRotationDate() == null) throw new IllegalStateException("Rotated set must have a rotation date");
    }

    public Boolean isLegalInStandard(Long id) {
        CardSet entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardSet not found: " + id));
        Boolean result = entity.isLegalInStandard();
        repository.save(entity);
        return result;
    }

    public Boolean isLegalInFormat(Long id, String format) {
        CardSet entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardSet not found: " + id));
        Boolean result = entity.isLegalInFormat(format);
        repository.save(entity);
        return result;
    }

    public Integer cardCountByRarity(Long id, String rarity) {
        CardSet entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardSet not found: " + id));
        Integer result = entity.cardCountByRarity(rarity);
        repository.save(entity);
        return result;
    }

    public void rotateOut(Long id) {
        CardSet entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardSet not found: " + id));
        entity.rotateOut();
        repository.save(entity);
    }
}
