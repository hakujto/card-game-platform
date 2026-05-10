package cardsproject.domain.cards;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "card_rulings")
public class CardRuling {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String rulingText = "";
    private LocalDate publishedAt;
    private String source = "";

    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getRulingText() { return rulingText; }
    public void setRulingText(String rulingText) { this.rulingText = rulingText; }
    public LocalDate getPublishedAt() { return publishedAt; }
    public void setPublishedAt(LocalDate publishedAt) { this.publishedAt = publishedAt; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
}
