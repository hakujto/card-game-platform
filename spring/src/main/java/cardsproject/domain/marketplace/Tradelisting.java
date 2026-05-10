package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "tradelistings")
public class Tradelisting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TradelistingListingTypeType listingType;
    private BigDecimal askingPrice;
    private BigDecimal auctionStartPrice;
    private BigDecimal auctionCurrentBid;
    private LocalDateTime auctionEndTime;
    private Boolean foil = false;
    @Enumerated(EnumType.STRING)
    private TradelistingConditionType condition;
    private Integer quantity = 1;
    @Enumerated(EnumType.STRING)
    private TradelistingStatusType status;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;

    @Column(name = "seller_id")
    private Long sellerId;
    @Column(name = "card_id")
    private Long cardId;
    @Column(name = "bids_id")
    private Long bidsId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TradelistingListingTypeType getListingType() { return listingType; }
    public void setListingType(TradelistingListingTypeType listingType) { this.listingType = listingType; }
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
    public TradelistingConditionType getCondition() { return condition; }
    public void setCondition(TradelistingConditionType condition) { this.condition = condition; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public TradelistingStatusType getStatus() { return status; }
    public void setStatus(TradelistingStatusType status) { this.status = status; }
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
    public Long getBidsId() { return bidsId; }
    public void setBidsId(Long bidsId) { this.bidsId = bidsId; }
}
