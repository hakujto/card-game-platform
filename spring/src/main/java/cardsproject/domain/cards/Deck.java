package cardsproject.domain.cards;

import jakarta.persistence.*;
import java.time.LocalDateTime;

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
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Column(name = "player_id")
    private Long playerId;

    // M2M: cards managed via join table
    // M2M: sideboard_cards managed via join table
    // M2M: tags managed via join table

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
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
}
