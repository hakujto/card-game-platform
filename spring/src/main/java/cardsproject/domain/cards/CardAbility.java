package cardsproject.domain.cards;

import jakarta.persistence.*;

@Entity
@Table(name = "card_abilitys")
public class CardAbility {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private CardAbilityAbilityTypeType abilityType;
    private String keyword;
    private String abilityText = "";
    @Enumerated(EnumType.STRING)
    private CardAbilityTimingType timing;

    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public CardAbilityAbilityTypeType getAbilityType() { return abilityType; }
    public void setAbilityType(CardAbilityAbilityTypeType abilityType) { this.abilityType = abilityType; }
    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }
    public String getAbilityText() { return abilityText; }
    public void setAbilityText(String abilityText) { this.abilityText = abilityText; }
    public CardAbilityTimingType getTiming() { return timing; }
    public void setTiming(CardAbilityTimingType timing) { this.timing = timing; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
}
