package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "tournaments")
public class Tournament {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    private String description;
    @Enumerated(EnumType.STRING)
    private TournamentFormatType format;
    @Enumerated(EnumType.STRING)
    private TournamentTournamentTypeType tournamentType;
    @Enumerated(EnumType.STRING)
    private TournamentStatusType status;
    private Integer maxPlayers = 0;
    private BigDecimal entryFee = new BigDecimal("0");
    private BigDecimal prizePool = new BigDecimal("0");
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Boolean isOnline = true;
    private String location;
    private String rulesText;
    private LocalDateTime createdAt;

    @Column(name = "season_id")
    private Long seasonId;
    @Column(name = "organizer_id")
    private Long organizerId;

    // M2M: judges managed via join table

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public TournamentFormatType getFormat() { return format; }
    public void setFormat(TournamentFormatType format) { this.format = format; }
    public TournamentTournamentTypeType getTournamentType() { return tournamentType; }
    public void setTournamentType(TournamentTournamentTypeType tournamentType) { this.tournamentType = tournamentType; }
    public TournamentStatusType getStatus() { return status; }
    public void setStatus(TournamentStatusType status) { this.status = status; }
    public Integer getMaxPlayers() { return maxPlayers; }
    public void setMaxPlayers(Integer maxPlayers) { this.maxPlayers = maxPlayers; }
    public BigDecimal getEntryFee() { return entryFee; }
    public void setEntryFee(BigDecimal entryFee) { this.entryFee = entryFee; }
    public BigDecimal getPrizePool() { return prizePool; }
    public void setPrizePool(BigDecimal prizePool) { this.prizePool = prizePool; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }
    public Boolean getIsOnline() { return isOnline; }
    public void setIsOnline(Boolean isOnline) { this.isOnline = isOnline; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getRulesText() { return rulesText; }
    public void setRulesText(String rulesText) { this.rulesText = rulesText; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Long getSeasonId() { return seasonId; }
    public void setSeasonId(Long seasonId) { this.seasonId = seasonId; }
    public Long getOrganizerId() { return organizerId; }
    public void setOrganizerId(Long organizerId) { this.organizerId = organizerId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void start() {
        throw new UnsupportedOperationException("start not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void cancel() {
        throw new UnsupportedOperationException("cancel not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void complete() {
        throw new UnsupportedOperationException("complete not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void generateRound() {
        throw new UnsupportedOperationException("generateRound not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal calculatePrizeDistribution() {
        throw new UnsupportedOperationException("calculatePrizeDistribution not implemented");
    }
    public void registerPlayer(Integer playerId, Integer deckId) {
        throw new UnsupportedOperationException("registerPlayer not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isFull() {
        throw new UnsupportedOperationException("isFull not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Tournament must allow between 2 and 512 players")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isMaxPlayersPositiveValid() {
        return (getMaxPlayers() == null || (getMaxPlayers() >= 2 && getMaxPlayers() <= 512));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Entry fee must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isEntryFeeNotNegativeValid() {
        return (getEntryFee() == null || getEntryFee().compareTo(new java.math.BigDecimal("0")) >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Prize pool must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPrizePoolNotNegativeValid() {
        return (getPrizePool() == null || getPrizePool().compareTo(new java.math.BigDecimal("0")) >= 0);
    }
}
