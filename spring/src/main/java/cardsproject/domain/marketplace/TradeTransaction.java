package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "trade_transactions")
public class TradeTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private BigDecimal finalPrice = BigDecimal.ZERO;
    private BigDecimal platformFee = BigDecimal.ZERO;
    @Enumerated(EnumType.STRING)
    private TradeTransactionStatusType status;
    private LocalDateTime completedAt;

    @Column(name = "listing_id")
    private Long listingId;
    @Column(name = "buyer_id")
    private Long buyerId;
    @Column(name = "seller_id")
    private Long sellerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BigDecimal getFinalPrice() { return finalPrice; }
    public void setFinalPrice(BigDecimal finalPrice) { this.finalPrice = finalPrice; }
    public BigDecimal getPlatformFee() { return platformFee; }
    public void setPlatformFee(BigDecimal platformFee) { this.platformFee = platformFee; }
    public TradeTransactionStatusType getStatus() { return status; }
    public void setStatus(TradeTransactionStatusType status) { this.status = status; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }
    public Long getBuyerId() { return buyerId; }
    public void setBuyerId(Long buyerId) { this.buyerId = buyerId; }
    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void complete() {
        throw new UnsupportedOperationException("complete not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void refund() {
        throw new UnsupportedOperationException("refund not implemented");
    }
    public void openDispute(String reason) {
        throw new UnsupportedOperationException("openDispute not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal sellerNet() {
        throw new UnsupportedOperationException("sellerNet not implemented");
    }
}
