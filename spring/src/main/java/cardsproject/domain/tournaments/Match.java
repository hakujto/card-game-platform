package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "matchs")
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer tableNumber;
    @Enumerated(EnumType.STRING)
    private MatchStatusType status;
    private Integer player1Wins = 0;
    private Integer player2Wins = 0;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private String resultNotes;

    @Column(name = "round_id")
    private Long roundId;
    @Column(name = "player1_id")
    private Long player1Id;
    @Column(name = "player2_id")
    private Long player2Id;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getTableNumber() { return tableNumber; }
    public void setTableNumber(Integer tableNumber) { this.tableNumber = tableNumber; }
    public MatchStatusType getStatus() { return status; }
    public void setStatus(MatchStatusType status) { this.status = status; }
    public Integer getPlayer1Wins() { return player1Wins; }
    public void setPlayer1Wins(Integer player1Wins) { this.player1Wins = player1Wins; }
    public Integer getPlayer2Wins() { return player2Wins; }
    public void setPlayer2Wins(Integer player2Wins) { this.player2Wins = player2Wins; }
    @JsonProperty("startedAt")
    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    @JsonProperty("endedAt")
    public LocalDateTime getEndedAt() { return endedAt; }
    public void setEndedAt(LocalDateTime endedAt) { this.endedAt = endedAt; }
    public String getResultNotes() { return resultNotes; }
    public void setResultNotes(String resultNotes) { this.resultNotes = resultNotes; }
    public Long getRoundId() { return roundId; }
    public void setRoundId(Long roundId) { this.roundId = roundId; }
    public Long getPlayer1Id() { return player1Id; }
    public void setPlayer1Id(Long player1Id) { this.player1Id = player1Id; }
    public Long getPlayer2Id() { return player2Id; }
    public void setPlayer2Id(Long player2Id) { this.player2Id = player2Id; }

    // ── Business operations ──────────────────────────────────────────
    public void recordResult(Integer p1Wins, Integer p2Wins) {
        // TODO: implement recordResult
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void finalizeResult() {
        // TODO: implement finalizeResult
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean determineWinner() {
        // TODO: implement determineWinner
        return null;
    }
    public void concede(Integer playerId) {
        // TODO: implement concede
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void draw() {
        // TODO: implement draw
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Win counts must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isWinsNotNegativeValid() {
        return ((getPlayer1Wins() == null || getPlayer1Wins() >= 0) && (getPlayer2Wins() == null || getPlayer2Wins() >= 0));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Win counts cannot exceed 2 in a best-of-3 match")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isMaxThreeGamesValid() {
        return ((getPlayer1Wins() == null || (getPlayer1Wins() >= 0 && getPlayer1Wins() <= 2)) && (getPlayer2Wins() == null || (getPlayer2Wins() >= 0 && getPlayer2Wins() <= 2)));
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<MatchStatusType, java.util.List<MatchStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(MatchStatusType.PENDING, java.util.List.of(MatchStatusType.ACTIVE, MatchStatusType.BYE)),
        java.util.Map.entry(MatchStatusType.ACTIVE, java.util.List.of(MatchStatusType.COMPLETED, MatchStatusType.DRAW))
        );

    public void assertTransition(MatchStatusType to) {
        java.util.List<MatchStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
