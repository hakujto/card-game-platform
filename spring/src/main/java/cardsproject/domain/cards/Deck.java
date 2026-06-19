package cardsproject.domain.cards;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "decks")
public class Deck {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    private String description;
    @Enumerated(EnumType.STRING)
    private DeckFormatType format;
    private Boolean isPublic = false;
    private Boolean isTournamentLegal = false;
    @Enumerated(EnumType.STRING)
    private DeckArchetypeType archetype;
    private Integer wins = 0;
    private Integer losses = 0;
    private Integer draws = 0;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // @ManyToOne -> Player, onDelete=CASCADE, relatedName=decks, via=players
    @Column(name = "player_id")
    private Long playerId;

    // M2M: cards -> Card, represented via DeckCard entity (through model); no direct field here
    // M2M: sideboard_cards -> Card, represented via DeckSideboardCard entity (through model); no direct field here
    // M2M: tags -> DeckTag, represented via DeckTagAssignment entity (through model); no direct field here

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public DeckFormatType getFormat() { return format; }
    public void setFormat(DeckFormatType format) { this.format = format; }
    public Boolean getIsPublic() { return isPublic; }
    public void setIsPublic(Boolean isPublic) { this.isPublic = isPublic; }
    public Boolean getIsTournamentLegal() { return isTournamentLegal; }
    public void setIsTournamentLegal(Boolean isTournamentLegal) { this.isTournamentLegal = isTournamentLegal; }
    public DeckArchetypeType getArchetype() { return archetype; }
    public void setArchetype(DeckArchetypeType archetype) { this.archetype = archetype; }
    public Integer getWins() { return wins; }
    public void setWins(Integer wins) { this.wins = wins; }
    public Integer getLosses() { return losses; }
    public void setLosses(Integer losses) { this.losses = losses; }
    public Integer getDraws() { return draws; }
    public void setDraws(Integer draws) { this.draws = draws; }
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    @JsonProperty("updatedAt")
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean validateSize() {
        // TODO: implement validateSize
        return null;
    }
    public void addCard(Integer cardId, Integer quantity) {
        // TODO: implement addCard
    }
    public void removeCard(Integer cardId) {
        // TODO: implement removeCard
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal winRate() {
        // TODO: implement winRate
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Deck clone() {
        // TODO: implement clone
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void publish() {
        // TODO: implement publish
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void unpublish() {
        // TODO: implement unpublish
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean certifyTournamentLegal() {
        // TODO: implement certifyTournamentLegal
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Deck wins count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isWinsNotNegativeValid() {
        return (getWins() == null || getWins() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Deck losses count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isLossesNotNegativeValid() {
        return (getLosses() == null || getLosses() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Deck draws count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDrawsNotNegativeValid() {
        return (getDraws() == null || getDraws() >= 0);
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    @PostPersist
    @PostUpdate
    public void recalculateTournamentLegal() {
        // TODO: implement recalculate_tournament_legal
    }
}
