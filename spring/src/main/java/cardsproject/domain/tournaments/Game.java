package cardsproject.domain.tournaments;

import jakarta.persistence.*;

@Entity
@Table(name = "games")
public class Game {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer gameNumber = 0;
    @Enumerated(EnumType.STRING)
    private GameWinnerSideType winnerSide;
    private Integer turnsPlayed;
    private Integer durationSeconds;
    @Enumerated(EnumType.STRING)
    private GameEndedByType endedBy;
    private String replayUrl;

    @Column(name = "match_id")
    private Long matchId;
    @Column(name = "winner_id")
    private Long winnerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getGameNumber() { return gameNumber; }
    public void setGameNumber(Integer gameNumber) { this.gameNumber = gameNumber; }
    public GameWinnerSideType getWinnerSide() { return winnerSide; }
    public void setWinnerSide(GameWinnerSideType winnerSide) { this.winnerSide = winnerSide; }
    public Integer getTurnsPlayed() { return turnsPlayed; }
    public void setTurnsPlayed(Integer turnsPlayed) { this.turnsPlayed = turnsPlayed; }
    public Integer getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(Integer durationSeconds) { this.durationSeconds = durationSeconds; }
    public GameEndedByType getEndedBy() { return endedBy; }
    public void setEndedBy(GameEndedByType endedBy) { this.endedBy = endedBy; }
    public String getReplayUrl() { return replayUrl; }
    public void setReplayUrl(String replayUrl) { this.replayUrl = replayUrl; }
    public Long getMatchId() { return matchId; }
    public void setMatchId(Long matchId) { this.matchId = matchId; }
    public Long getWinnerId() { return winnerId; }
    public void setWinnerId(Long winnerId) { this.winnerId = winnerId; }

    // ── Business operations ──────────────────────────────────────────
    public void recordWinner(String winnerSide) {
        throw new UnsupportedOperationException("recordWinner not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal durationMinutes() {
        throw new UnsupportedOperationException("durationMinutes not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Game number must be between 1 and 3 (best-of-3)")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isGameNumberRangeValid() {
        return (getGameNumber() == null || (getGameNumber() >= 1 && getGameNumber() <= 3));
    }
}
