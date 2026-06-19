package cardsproject.domain.cards;

import jakarta.persistence.*;

@Entity
@Table(name = "deck_tag_assignments")
public class DeckTagAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    // @ManyToOne -> Deck, onDelete=CASCADE, relatedName=tag_assignments
    @Column(name = "deck_id")
    private Long deckId;
    // @ManyToOne -> DeckTag, onDelete=CASCADE, relatedName=deck_assignments
    @Column(name = "tag_id")
    private Long tagId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getDeckId() { return deckId; }
    public void setDeckId(Long deckId) { this.deckId = deckId; }
    public Long getTagId() { return tagId; }
    public void setTagId(Long tagId) { this.tagId = tagId; }
}
