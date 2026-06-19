package cardsproject.domain.cards;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "deck_cards")
public class DeckCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantity = 1;
    private Boolean isCommander = false;

    // @ManyToOne -> Deck, onDelete=CASCADE, relatedName=deck_cards
    @Column(name = "deck_id")
    private Long deckId;
    // @ManyToOne -> Card, onDelete=PROTECT, relatedName=deck_cards
    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Boolean getIsCommander() { return isCommander; }
    public void setIsCommander(Boolean isCommander) { this.isCommander = isCommander; }
    public Long getDeckId() { return deckId; }
    public void setDeckId(Long deckId) { this.deckId = deckId; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }

    // ── Business operations ──────────────────────────────────────────
    public void increment(Integer amount) {
        // TODO: implement increment
    }
    public void decrement(Integer amount) {
        // TODO: implement decrement
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "A deck can contain between 1 and 4 copies of a card")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isQuantityRangeValid() {
        return (getQuantity() == null || (getQuantity() >= 1 && getQuantity() <= 4));
    }
}
