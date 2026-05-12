package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "draft_sessions")
public class DraftSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private DraftSessionStatusType status;
    @Enumerated(EnumType.STRING)
    private DraftSessionDraftTypeType draftType;
    private Integer seats = 8;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    @Column(name = "card_set_id")
    private Long cardSetId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public DraftSessionStatusType getStatus() { return status; }
    public void setStatus(DraftSessionStatusType status) { this.status = status; }
    public DraftSessionDraftTypeType getDraftType() { return draftType; }
    public void setDraftType(DraftSessionDraftTypeType draftType) { this.draftType = draftType; }
    public Integer getSeats() { return seats; }
    public void setSeats(Integer seats) { this.seats = seats; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    public Long getCardSetId() { return cardSetId; }
    public void setCardSetId(Long cardSetId) { this.cardSetId = cardSetId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void start() {
        throw new UnsupportedOperationException("start not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void abandon() {
        throw new UnsupportedOperationException("abandon not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void complete() {
        throw new UnsupportedOperationException("complete not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isFull() {
        throw new UnsupportedOperationException("isFull not implemented");
    }
}
