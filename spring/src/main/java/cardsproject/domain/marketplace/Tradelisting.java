package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "trade_listings")
public class TradeListing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TradeListingStatusType status;
    @Enumerated(EnumType.STRING)
    private TradeListingListingTypeType listingType;
    private BigDecimal askingPrice;
    private BigDecimal auctionStartPrice;
    private BigDecimal auctionCurrentBid;
    private LocalDateTime auctionEndTime;
    private Boolean foil = false;
    @Enumerated(EnumType.STRING)
    private TradeListingConditionType condition;
    private Integer quantity = 1;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;

    @Column(name = "seller_id")
    private Long sellerId;
    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TradeListingStatusType getStatus() { return status; }
    public void setStatus(TradeListingStatusType status) { this.status = status; }
    public TradeListingListingTypeType getListingType() { return listingType; }
    public void setListingType(TradeListingListingTypeType listingType) { this.listingType = listingType; }
    public BigDecimal getAskingPrice() { return askingPrice; }
    public void setAskingPrice(BigDecimal askingPrice) { this.askingPrice = askingPrice; }
    public BigDecimal getAuctionStartPrice() { return auctionStartPrice; }
    public void setAuctionStartPrice(BigDecimal auctionStartPrice) { this.auctionStartPrice = auctionStartPrice; }
    public BigDecimal getAuctionCurrentBid() { return auctionCurrentBid; }
    public void setAuctionCurrentBid(BigDecimal auctionCurrentBid) { this.auctionCurrentBid = auctionCurrentBid; }
    public LocalDateTime getAuctionEndTime() { return auctionEndTime; }
    public void setAuctionEndTime(LocalDateTime auctionEndTime) { this.auctionEndTime = auctionEndTime; }
    public Boolean getFoil() { return foil; }
    public void setFoil(Boolean foil) { this.foil = foil; }
    public TradeListingConditionType getCondition() { return condition; }
    public void setCondition(TradeListingConditionType condition) { this.condition = condition; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void close() {
        // TODO: implement close
    }
    public void extend(Integer days) {
        // TODO: implement extend
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void cancel() {
        // TODO: implement cancel
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isExpired() {
        // TODO: implement isExpired
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void finalizeAuction() {
        // TODO: implement finalizeAuction
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Listing quantity must be between 1 and 9999")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isQuantityPositiveValid() {
        return (getQuantity() == null || (getQuantity() >= 1 && getQuantity() <= 9999));
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<TradeListingStatusType, java.util.List<TradeListingStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(TradeListingStatusType.PENDING, java.util.List.of(TradeListingStatusType.ACTIVE)),
        java.util.Map.entry(TradeListingStatusType.ACTIVE, java.util.List.of(TradeListingStatusType.SOLD, TradeListingStatusType.EXPIRED, TradeListingStatusType.CANCELLED))
        );

    public void assertTransition(TradeListingStatusType to) {
        java.util.List<TradeListingStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
