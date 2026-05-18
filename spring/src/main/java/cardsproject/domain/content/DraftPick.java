package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "draft_picks")
public class DraftPick {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer pickNumber = 0;
    private Integer packNumber = 0;
    private LocalDateTime pickedAt;

    @Column(name = "participant_id")
    private Long participantId;
    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getPickNumber() { return pickNumber; }
    public void setPickNumber(Integer pickNumber) { this.pickNumber = pickNumber; }
    public Integer getPackNumber() { return packNumber; }
    public void setPackNumber(Integer packNumber) { this.packNumber = packNumber; }
    public LocalDateTime getPickedAt() { return pickedAt; }
    public void setPickedAt(LocalDateTime pickedAt) { this.pickedAt = pickedAt; }
    public Long getParticipantId() { return participantId; }
    public void setParticipantId(Long participantId) { this.participantId = participantId; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isFirstPick() {
        throw new UnsupportedOperationException("isFirstPick not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Pick number must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPickNumberPositiveValid() {
        return (getPickNumber() == null || getPickNumber() > 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Pack number must be between 1 and 3")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPackNumberRangeValid() {
        return (getPackNumber() == null || (getPackNumber() >= 1 && getPackNumber() <= 3));
    }
}
