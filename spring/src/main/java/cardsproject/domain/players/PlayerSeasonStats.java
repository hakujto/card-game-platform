package cardsproject.domain.players;

import jakarta.persistence.*;

@Entity
@Table(name = "player_season_statss")
public class PlayerSeasonStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer wins = 0;
    private Integer losses = 0;
    private Integer draws = 0;
    private Integer tournamentWins = 0;
    @Enumerated(EnumType.STRING)
    private PlayerSeasonStatsHighestRankType highestRank;
    private Integer seasonPoints = 0;

    // @ManyToOne -> Player, onDelete=CASCADE, relatedName=season_stats
    @Column(name = "player_id")
    private Long playerId;
    // @ManyToOne -> Season, onDelete=CASCADE, relatedName=player_stats, via=tournaments
    @Column(name = "season_id")
    private Long seasonId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getWins() { return wins; }
    public void setWins(Integer wins) { this.wins = wins; }
    public Integer getLosses() { return losses; }
    public void setLosses(Integer losses) { this.losses = losses; }
    public Integer getDraws() { return draws; }
    public void setDraws(Integer draws) { this.draws = draws; }
    public Integer getTournamentWins() { return tournamentWins; }
    public void setTournamentWins(Integer tournamentWins) { this.tournamentWins = tournamentWins; }
    public PlayerSeasonStatsHighestRankType getHighestRank() { return highestRank; }
    public void setHighestRank(PlayerSeasonStatsHighestRankType highestRank) { this.highestRank = highestRank; }
    public Integer getSeasonPoints() { return seasonPoints; }
    public void setSeasonPoints(Integer seasonPoints) { this.seasonPoints = seasonPoints; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
    public Long getSeasonId() { return seasonId; }
    public void setSeasonId(Long seasonId) { this.seasonId = seasonId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal winRate() {
        // TODO: implement winRate
        return null;
    }
    public void addPoints(Integer points) {
        // TODO: implement addPoints
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void recordTournamentWin() {
        // TODO: implement recordTournamentWin
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Season wins must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isWinsNotNegativeValid() {
        return (getWins() == null || getWins() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Season losses must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isLossesNotNegativeValid() {
        return (getLosses() == null || getLosses() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Season tournament wins must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isTournamentWinsNotNegativeValid() {
        return (getTournamentWins() == null || getTournamentWins() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Season points must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isSeasonPointsNotNegativeValid() {
        return (getSeasonPoints() == null || getSeasonPoints() >= 0);
    }
}
