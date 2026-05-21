package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "tournament_rounds")
public class TournamentRound {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer roundNumber = 0;
    @Enumerated(EnumType.STRING)
    private TournamentRoundStatusType status;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer timeLimitMinutes = 50;

    @Column(name = "tournament_id")
    private Long tournamentId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getRoundNumber() { return roundNumber; }
    public void setRoundNumber(Integer roundNumber) { this.roundNumber = roundNumber; }
    public TournamentRoundStatusType getStatus() { return status; }
    public void setStatus(TournamentRoundStatusType status) { this.status = status; }
    @JsonProperty("startedAt")
    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    @JsonProperty("endedAt")
    public LocalDateTime getEndedAt() { return endedAt; }
    public void setEndedAt(LocalDateTime endedAt) { this.endedAt = endedAt; }
    public Integer getTimeLimitMinutes() { return timeLimitMinutes; }
    public void setTimeLimitMinutes(Integer timeLimitMinutes) { this.timeLimitMinutes = timeLimitMinutes; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void start() {
        // TODO: implement start
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void complete() {
        // TODO: implement complete
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void generatePairings() {
        // TODO: implement generatePairings
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isTimeExpired() {
        // TODO: implement isTimeExpired
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Round number must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isRoundNumberPositiveValid() {
        return (getRoundNumber() == null || getRoundNumber() > 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Round time limit must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isTimeLimitPositiveValid() {
        return (getTimeLimitMinutes() == null || getTimeLimitMinutes() > 0);
    }
}
