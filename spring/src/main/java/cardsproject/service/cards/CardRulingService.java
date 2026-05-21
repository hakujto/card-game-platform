package cardsproject.service.cards;

import cardsproject.domain.cards.CardRuling;
import cardsproject.repository.cards.CardRulingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardRulingService {

    private final CardRulingRepository repository;

    public CardRulingService(CardRulingRepository repository) {
        this.repository = repository;
    }

    public List<CardRuling> findAll() {
        return repository.findAll();
    }

    public Optional<CardRuling> findById(Long id) {
        return repository.findById(id);
    }

    public CardRuling save(CardRuling entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(CardRuling entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("rulingText") && patch.get("rulingText") != null) entity.setRulingText(patch.get("rulingText").toString());
        if (patch.containsKey("publishedAt") && patch.get("publishedAt") != null) entity.setPublishedAt(java.time.LocalDate.parse(patch.get("publishedAt").toString()));
        if (patch.containsKey("source") && patch.get("source") != null) entity.setSource(patch.get("source").toString());
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
    }

    public Boolean isCurrent(Long id) {
        CardRuling entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardRuling not found: " + id));
        Boolean result = entity.isCurrent();
        repository.save(entity);
        return result;
    }

    public Boolean supersedesPrevious(Long id) {
        CardRuling entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("CardRuling not found: " + id));
        Boolean result = entity.supersedesPrevious();
        repository.save(entity);
        return result;
    }
}
