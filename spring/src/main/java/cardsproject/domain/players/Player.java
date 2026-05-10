package cardsproject.domain.players;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "players")
public class Player {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

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

    @Column(name = "user_id")
    private Long userId;
    @Column(name = "season_stats_id")
    private Long seasonStatsId;

    // M2M: achievements managed via join table
    // M2M: friends managed via join table

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
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getLastActiveAt() { return lastActiveAt; }
    public void setLastActiveAt(LocalDateTime lastActiveAt) { this.lastActiveAt = lastActiveAt; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getSeasonStatsId() { return seasonStatsId; }
    public void setSeasonStatsId(Long seasonStatsId) { this.seasonStatsId = seasonStatsId; }
}
