package cardsproject.service.cards;

import cardsproject.domain.cards.CardSet;
import cardsproject.repository.cards.CardSetRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.cards.CardSetSetTypeType;

@Service
public class CardSetService {

    private final CardSetRepository repository;

    public CardSetService(CardSetRepository repository) {
        this.repository = repository;
    }

    public List<CardSet> findAll() {
        return repository.findAll();
    }

    public List<CardSet> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getCode() != null && e.getCode().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
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

    public void applyPatch(CardSet entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("code") && patch.get("code") != null) entity.setCode(patch.get("code").toString());
        if (patch.containsKey("releaseDate") && patch.get("releaseDate") != null) entity.setReleaseDate(java.time.LocalDate.parse(patch.get("releaseDate").toString()));
        if (patch.containsKey("rotationDate") && patch.get("rotationDate") != null) entity.setRotationDate(java.time.LocalDate.parse(patch.get("rotationDate").toString()));
        if (patch.containsKey("setType")) entity.setSetType(CardSetSetTypeType.valueOf(patch.get("setType").toString()));
        if (patch.containsKey("totalCards") && patch.get("totalCards") != null) entity.setTotalCards(Integer.valueOf(patch.get("totalCards").toString()));
        if (patch.containsKey("isRotated") && patch.get("isRotated") != null) entity.setIsRotated(Boolean.valueOf(patch.get("isRotated").toString()));
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("logoUrl") && patch.get("logoUrl") != null) entity.setLogoUrl(patch.get("logoUrl").toString());
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
