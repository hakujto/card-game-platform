package cardsproject.domain.players;

import jakarta.persistence.*;

@Entity
@Table(name = "achievements")
public class Achievement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    private String description = "";
    private String iconUrl;
    private Integer points = 10;
    @Enumerated(EnumType.STRING)
    private AchievementRarityType rarity;
    private Boolean isHidden = false;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }
    public Integer getPoints() { return points; }
    public void setPoints(Integer points) { this.points = points; }
    public AchievementRarityType getRarity() { return rarity; }
    public void setRarity(AchievementRarityType rarity) { this.rarity = rarity; }
    public Boolean getIsHidden() { return isHidden; }
    public void setIsHidden(Boolean isHidden) { this.isHidden = isHidden; }

    // ── Business operations ──────────────────────────────────────────
    public Integer pointValue(Integer multiplier) {
        throw new UnsupportedOperationException("pointValue not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void reveal() {
        throw new UnsupportedOperationException("reveal not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Achievement must award at least one point")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPointsPositiveValid() {
        return (getPoints() == null || getPoints() > 0);
    }
}
