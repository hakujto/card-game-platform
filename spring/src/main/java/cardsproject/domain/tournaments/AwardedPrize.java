package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "awarded_prizes")
public class AwardedPrize {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer finalPlacement = 0;
    private LocalDateTime awardedAt;
    private Boolean claimed = false;
    private LocalDateTime claimedAt;

    @Column(name = "prize_id")
    private Long prizeId;
    @Column(name = "player_id")
    private Long playerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getFinalPlacement() { return finalPlacement; }
    public void setFinalPlacement(Integer finalPlacement) { this.finalPlacement = finalPlacement; }
    public LocalDateTime getAwardedAt() { return awardedAt; }
    public void setAwardedAt(LocalDateTime awardedAt) { this.awardedAt = awardedAt; }
    public Boolean getClaimed() { return claimed; }
    public void setClaimed(Boolean claimed) { this.claimed = claimed; }
    public LocalDateTime getClaimedAt() { return claimedAt; }
    public void setClaimedAt(LocalDateTime claimedAt) { this.claimedAt = claimedAt; }
    public Long getPrizeId() { return prizeId; }
    public void setPrizeId(Long prizeId) { this.prizeId = prizeId; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
}
