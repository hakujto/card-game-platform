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
    private Integer timePerPickSeconds = 30;
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
    public Integer getTimePerPickSeconds() { return timePerPickSeconds; }
    public void setTimePerPickSeconds(Integer timePerPickSeconds) { this.timePerPickSeconds = timePerPickSeconds; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    public Long getCardSetId() { return cardSetId; }
    public void setCardSetId(Long cardSetId) { this.cardSetId = cardSetId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void start() {
        // TODO: implement start
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void abandon() {
        // TODO: implement abandon
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void complete() {
        // TODO: implement complete
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isFull() {
        // TODO: implement isFull
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Draft session must have between 2 and 16 seats")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isSeatsRangeValid() {
        return (getSeats() == null || (getSeats() >= 2 && getSeats() <= 16));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Time per pick must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isTimePerPickPositiveValid() {
        return (getTimePerPickSeconds() == null || getTimePerPickSeconds() > 0);
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<DraftSessionStatusType, java.util.List<DraftSessionStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(DraftSessionStatusType.WAITINGFORPLAYERS, java.util.List.of(DraftSessionStatusType.DRAFTING, DraftSessionStatusType.ABANDONED)),
        java.util.Map.entry(DraftSessionStatusType.DRAFTING, java.util.List.of(DraftSessionStatusType.COMPLETED, DraftSessionStatusType.ABANDONED))
        );

    public void assertTransition(DraftSessionStatusType to) {
        java.util.List<DraftSessionStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
