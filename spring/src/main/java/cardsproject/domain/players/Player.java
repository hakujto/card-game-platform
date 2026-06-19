package cardsproject.domain.players;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "players")
public class Player {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String displayName = "";
    @Enumerated(EnumType.STRING)
    private PlayerRankType rank;
    private Integer rating = 1000;
    private Integer peakRating = 1000;
    private String bio;
    private String countryCode;
    private String avatarUrl;
    @Enumerated(EnumType.STRING)
    private PlayerPreferredFormatType preferredFormat;
    private Boolean isVerified = false;
    private LocalDateTime createdAt;
    private LocalDateTime lastActiveAt;

    // @OneToOne -> User, onDelete=CASCADE, relatedName=player_profile
    @Column(name = "user_id")
    private Long userId;

    // M2M: achievements -> Achievement, represented via PlayerAchievement entity (through model); no direct field here
    // M2M: friends -> Player, represented via Friendship entity (through model); no direct field here

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public PlayerRankType getRank() { return rank; }
    public void setRank(PlayerRankType rank) { this.rank = rank; }
    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }
    public Integer getPeakRating() { return peakRating; }
    public void setPeakRating(Integer peakRating) { this.peakRating = peakRating; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getCountryCode() { return countryCode; }
    public void setCountryCode(String countryCode) { this.countryCode = countryCode; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
    public PlayerPreferredFormatType getPreferredFormat() { return preferredFormat; }
    public void setPreferredFormat(PlayerPreferredFormatType preferredFormat) { this.preferredFormat = preferredFormat; }
    public Boolean getIsVerified() { return isVerified; }
    public void setIsVerified(Boolean isVerified) { this.isVerified = isVerified; }
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    @JsonProperty("lastActiveAt")
    public LocalDateTime getLastActiveAt() { return lastActiveAt; }
    public void setLastActiveAt(LocalDateTime lastActiveAt) { this.lastActiveAt = lastActiveAt; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean promote() {
        // TODO: implement promote
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean demote() {
        // TODO: implement demote
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void recordWin() {
        // TODO: implement recordWin
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void recordLoss() {
        // TODO: implement recordLoss
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal winRate() {
        // TODO: implement winRate
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void verify() {
        // TODO: implement verify
    }
    public void updateRating(Integer delta) {
        // TODO: implement updateRating
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Rating must be between 0 and 9999")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isRatingRangeValid() {
        return (getRating() == null || (getRating() >= 0 && getRating() <= 9999));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Peak rating must be greater than or equal to current rating")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPeakRatingGteRatingValid() {
        return (getPeakRating() == null || (getRating() != null && getPeakRating() >= getRating()));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Display name must not be empty")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDisplayNameNotEmptyValid() {
        return getDisplayName() != null;
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    @PostPersist
    public void initializeCollection() {
        // TODO: implement initialize_collection
    }
    @PostUpdate
    public void updateRank() {
        // TODO: implement update_rank
    }
}
