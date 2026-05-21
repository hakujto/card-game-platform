package cardsproject.service.cards;

import cardsproject.domain.cards.Card;
import cardsproject.repository.cards.CardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.Objects;
import cardsproject.domain.cards.CardCardTypeType;
import cardsproject.domain.cards.CardRarityType;
import cardsproject.domain.cards.CardManaColorsType;
import cardsproject.domain.cards.CardLegalFormatsType;

@Service
public class CardService {

    private final CardRepository repository;

    public CardService(CardRepository repository) {
        this.repository = repository;
    }

    public List<Card> findAll() {
        return repository.findAll();
    }

    public List<Card> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getArtistName() != null && e.getArtistName().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
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

    public void applyPatch(Card entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("cardType")) entity.setCardType(CardCardTypeType.valueOf(patch.get("cardType").toString()));
        if (patch.containsKey("rarity")) entity.setRarity(CardRarityType.valueOf(patch.get("rarity").toString()));
        if (patch.containsKey("manaCost") && patch.get("manaCost") != null) entity.setManaCost(Integer.valueOf(patch.get("manaCost").toString()));
        if (patch.containsKey("manaColors")) entity.setManaColors(CardManaColorsType.valueOf(patch.get("manaColors").toString()));
        if (patch.containsKey("attack") && patch.get("attack") != null) entity.setAttack(Integer.valueOf(patch.get("attack").toString()));
        if (patch.containsKey("defense") && patch.get("defense") != null) entity.setDefense(Integer.valueOf(patch.get("defense").toString()));
        if (patch.containsKey("loyalty") && patch.get("loyalty") != null) entity.setLoyalty(Integer.valueOf(patch.get("loyalty").toString()));
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("flavorText") && patch.get("flavorText") != null) entity.setFlavorText(patch.get("flavorText").toString());
        if (patch.containsKey("imageUrl") && patch.get("imageUrl") != null) entity.setImageUrl(patch.get("imageUrl").toString());
        if (patch.containsKey("artistName") && patch.get("artistName") != null) entity.setArtistName(patch.get("artistName").toString());
        if (patch.containsKey("legalFormats")) entity.setLegalFormats(CardLegalFormatsType.valueOf(patch.get("legalFormats").toString()));
        if (patch.containsKey("isBanned") && patch.get("isBanned") != null) entity.setIsBanned(Boolean.valueOf(patch.get("isBanned").toString()));
        if (patch.containsKey("isRestricted") && patch.get("isRestricted") != null) entity.setIsRestricted(Boolean.valueOf(patch.get("isRestricted").toString()));
        if (patch.containsKey("powerLevel") && patch.get("powerLevel") != null) entity.setPowerLevel(Integer.valueOf(patch.get("powerLevel").toString()));
        if (patch.containsKey("setId") && patch.get("setId") != null) entity.setSetId(Long.valueOf(patch.get("setId").toString()));
    }
    private void validate(Card entity) {
        if (CardCardTypeType.CREATURE.equals(entity.getCardType()) && !(entity.getAttack() != null && entity.getDefense() != null)) throw new IllegalStateException("Creature card must have attack and defense");
        if (CardCardTypeType.PLANESWALKER.equals(entity.getCardType()) && entity.getLoyalty() == null) throw new IllegalStateException("Planeswalker card must have loyalty");
        if (CardCardTypeType.LAND.equals(entity.getCardType()) && !(Objects.equals(entity.getManaCost(), 0))) throw new IllegalStateException("Land card must have zero mana cost");
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
