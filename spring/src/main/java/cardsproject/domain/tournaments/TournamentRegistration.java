package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tournament_registrations")
public class TournamentRegistration {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TournamentRegistrationStatusType status;
    private Integer seed;
    private Integer finalStanding;
    private Integer pointsEarned = 0;
    private LocalDateTime registeredAt;

    @Column(name = "tournament_id")
    private Long tournamentId;
    @Column(name = "player_id")
    private Long playerId;
    @Column(name = "deck_id")
    private Long deckId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TournamentRegistrationStatusType getStatus() { return status; }
    public void setStatus(TournamentRegistrationStatusType status) { this.status = status; }
    public Integer getSeed() { return seed; }
    public void setSeed(Integer seed) { this.seed = seed; }
    public Integer getFinalStanding() { return finalStanding; }
    public void setFinalStanding(Integer finalStanding) { this.finalStanding = finalStanding; }
    public Integer getPointsEarned() { return pointsEarned; }
    public void setPointsEarned(Integer pointsEarned) { this.pointsEarned = pointsEarned; }
    public LocalDateTime getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(LocalDateTime registeredAt) { this.registeredAt = registeredAt; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
    public Long getDeckId() { return deckId; }
    public void setDeckId(Long deckId) { this.deckId = deckId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void withdraw() {
        throw new UnsupportedOperationException("withdraw not implemented");
    }
    public void disqualify(String reason) {
        throw new UnsupportedOperationException("disqualify not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void promoteFromWaitlist() {
        throw new UnsupportedOperationException("promoteFromWaitlist not implemented");
    }
}
