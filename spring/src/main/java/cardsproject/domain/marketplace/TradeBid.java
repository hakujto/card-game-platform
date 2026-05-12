package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "trade_bids")
public class TradeBid {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private BigDecimal amount = BigDecimal.ZERO;
    private LocalDateTime placedAt;
    private Boolean isWinning = false;

    @Column(name = "listing_id")
    private Long listingId;
    @Column(name = "bidder_id")
    private Long bidderId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public LocalDateTime getPlacedAt() { return placedAt; }
    public void setPlacedAt(LocalDateTime placedAt) { this.placedAt = placedAt; }
    public Boolean getIsWinning() { return isWinning; }
    public void setIsWinning(Boolean isWinning) { this.isWinning = isWinning; }
    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }
    public Long getBidderId() { return bidderId; }
    public void setBidderId(Long bidderId) { this.bidderId = bidderId; }

    // ── Business operations ──────────────────────────────────────────
    public Boolean outbidBy(java.math.BigDecimal newAmount) {
        throw new UnsupportedOperationException("outbidBy not implemented");
    }
}
