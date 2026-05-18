package cardsproject.service.cards;

import cardsproject.domain.cards.Card;
import cardsproject.repository.cards.CardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.cards.CardCardTypeType;

@Service
public class CardService {

    private final CardRepository repository;

    public CardService(CardRepository repository) {
        this.repository = repository;
    }

    public List<Card> findAll() {
        return repository.findAll();
    }

    public Optional<Card> findById(Long id) {
        return repository.findById(id);
    }

    public Card save(Card entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Card entity) {
        if (CardCardTypeType.CREATURE.equals(entity.getCardType()) && !(entity.getAttack() != null && entity.getDefense() != null)) throw new IllegalStateException("Creature card must have attack and defense");
        if (CardCardTypeType.PLANESWALKER.equals(entity.getCardType()) && entity.getLoyalty() == null) throw new IllegalStateException("Planeswalker card must have loyalty");
        if (!CardCardTypeType.PLANESWALKER.equals(entity.getCardType()) && entity.getLoyalty() != null) throw new IllegalStateException("Only Planeswalker cards can have loyalty");
        if (Boolean.TRUE.equals(entity.getIsBanned()) && true) throw new IllegalStateException("banned_card_not_in_legal_formats");
    }

    public void ban(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.ban();
        repository.save(entity);
    }

    public void unban(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.unban();
        repository.save(entity);
    }

    public void restrict(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.restrict();
        repository.save(entity);
    }

    public void unrestrict(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        entity.unrestrict();
        repository.save(entity);
    }

    public java.math.BigDecimal calculateValue(Long id) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        java.math.BigDecimal result = entity.calculateValue();
        repository.save(entity);
        return result;
    }

    public java.math.BigDecimal applyRarityBonus(Long id, Integer multiplier) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        java.math.BigDecimal result = entity.applyRarityBonus(multiplier);
        repository.save(entity);
        return result;
    }

    public Boolean isLegalInFormat(Long id, String format) {
        Card entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Card not found: " + id));
        Boolean result = entity.isLegalInFormat(format);
        repository.save(entity);
        return result;
    }
}
