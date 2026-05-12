package cardsproject.domain.cards;

import jakarta.persistence.*;

@Entity
@Table(name = "cards")
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    @Enumerated(EnumType.STRING)
    private CardCardTypeType cardType;
    @Enumerated(EnumType.STRING)
    private CardRarityType rarity;
    private Integer manaCost = 0;
    @Enumerated(EnumType.STRING)
    private CardManaColorsType manaColors;
    private Integer attack;
    private Integer defense;
    private Integer loyalty;
    private String description = "";
    private String flavorText;
    private String imageUrl;
    private String artistName;
    @Enumerated(EnumType.STRING)
    private CardLegalFormatsType legalFormats;
    private Boolean isBanned = false;
    private Boolean isRestricted = false;
    private Integer powerLevel = 1;

    @Column(name = "set_id")
    private Long setId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public CardCardTypeType getCardType() { return cardType; }
    public void setCardType(CardCardTypeType cardType) { this.cardType = cardType; }
    public CardRarityType getRarity() { return rarity; }
    public void setRarity(CardRarityType rarity) { this.rarity = rarity; }
    public Integer getManaCost() { return manaCost; }
    public void setManaCost(Integer manaCost) { this.manaCost = manaCost; }
    public CardManaColorsType getManaColors() { return manaColors; }
    public void setManaColors(CardManaColorsType manaColors) { this.manaColors = manaColors; }
    public Integer getAttack() { return attack; }
    public void setAttack(Integer attack) { this.attack = attack; }
    public Integer getDefense() { return defense; }
    public void setDefense(Integer defense) { this.defense = defense; }
    public Integer getLoyalty() { return loyalty; }
    public void setLoyalty(Integer loyalty) { this.loyalty = loyalty; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getFlavorText() { return flavorText; }
    public void setFlavorText(String flavorText) { this.flavorText = flavorText; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }
    public CardLegalFormatsType getLegalFormats() { return legalFormats; }
    public void setLegalFormats(CardLegalFormatsType legalFormats) { this.legalFormats = legalFormats; }
    public Boolean getIsBanned() { return isBanned; }
    public void setIsBanned(Boolean isBanned) { this.isBanned = isBanned; }
    public Boolean getIsRestricted() { return isRestricted; }
    public void setIsRestricted(Boolean isRestricted) { this.isRestricted = isRestricted; }
    public Integer getPowerLevel() { return powerLevel; }
    public void setPowerLevel(Integer powerLevel) { this.powerLevel = powerLevel; }
    public Long getSetId() { return setId; }
    public void setSetId(Long setId) { this.setId = setId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void ban() {
        throw new UnsupportedOperationException("ban not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void unban() {
        throw new UnsupportedOperationException("unban not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void restrict() {
        throw new UnsupportedOperationException("restrict not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void unrestrict() {
        throw new UnsupportedOperationException("unrestrict not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal calculateValue() {
        throw new UnsupportedOperationException("calculateValue not implemented");
    }
}
