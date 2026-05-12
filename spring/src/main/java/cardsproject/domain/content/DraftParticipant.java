package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "draft_participants")
public class DraftParticipant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer seatNumber = 0;
    private LocalDateTime joinedAt;

    @Column(name = "session_id")
    private Long sessionId;
    @Column(name = "player_id")
    private Long playerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getSeatNumber() { return seatNumber; }
    public void setSeatNumber(Integer seatNumber) { this.seatNumber = seatNumber; }
    public LocalDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(LocalDateTime joinedAt) { this.joinedAt = joinedAt; }
    public Long getSessionId() { return sessionId; }
    public void setSessionId(Long sessionId) { this.sessionId = sessionId; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }

    // ── Business operations ──────────────────────────────────────────
    public void pickCard(Integer cardId, Integer packNumber) {
        throw new UnsupportedOperationException("pickCard not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer draftedCardCount() {
        throw new UnsupportedOperationException("draftedCardCount not implemented");
    }
}
