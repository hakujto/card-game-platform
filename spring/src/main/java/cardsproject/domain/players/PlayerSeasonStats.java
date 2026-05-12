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

    @Column(name = "player_id")
    private Long playerId;
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
        throw new UnsupportedOperationException("winRate not implemented");
    }
    public void addPoints(Integer points) {
        throw new UnsupportedOperationException("addPoints not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void recordTournamentWin() {
        throw new UnsupportedOperationException("recordTournamentWin not implemented");
    }
}
