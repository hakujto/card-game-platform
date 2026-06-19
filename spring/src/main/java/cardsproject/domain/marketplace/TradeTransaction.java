package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

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

    // @OneToOne -> TradeListing, onDelete=PROTECT, relatedName=transaction
    @Column(name = "listing_id")
    private Long listingId;
    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=purchases, via=players
    @Column(name = "buyer_id")
    private Long buyerId;
    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=sales, via=players
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
    @JsonProperty("completedAt")
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
        // TODO: implement complete
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void refund() {
        // TODO: implement refund
    }
    public void openDispute(String reason) {
        // TODO: implement openDispute
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal sellerNet() {
        // TODO: implement sellerNet
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Platform fee cannot exceed the final price")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isFeeNotExceedPriceValid() {
        return (getPlatformFee() == null || (getFinalPrice() != null && getPlatformFee().compareTo(getFinalPrice()) <= 0));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Platform fee must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isFeeNotNegativeValid() {
        return (getPlatformFee() == null || getPlatformFee().compareTo(new java.math.BigDecimal("0")) >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Transaction final price must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isFinalPricePositiveValid() {
        return (getFinalPrice() == null || getFinalPrice().compareTo(new java.math.BigDecimal("0")) > 0);
    }
}
