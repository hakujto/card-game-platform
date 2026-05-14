package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private OrderStatusType status;
    private BigDecimal total = new BigDecimal("0");
    private BigDecimal discountApplied = new BigDecimal("0");
    private String currency = "USD";
    @Enumerated(EnumType.STRING)
    private OrderPaymentMethodType paymentMethod;
    private String paymentReference;
    private String shippingAddress;
    private String trackingNumber;
    private LocalDateTime createdAt;
    private LocalDateTime paidAt;
    private LocalDateTime shippedAt;

    @Column(name = "player_id")
    private Long playerId;
    @Column(name = "coupon_id")
    private Long couponId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public OrderStatusType getStatus() { return status; }
    public void setStatus(OrderStatusType status) { this.status = status; }
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    public BigDecimal getDiscountApplied() { return discountApplied; }
    public void setDiscountApplied(BigDecimal discountApplied) { this.discountApplied = discountApplied; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public OrderPaymentMethodType getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(OrderPaymentMethodType paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
    public LocalDateTime getShippedAt() { return shippedAt; }
    public void setShippedAt(LocalDateTime shippedAt) { this.shippedAt = shippedAt; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
    public Long getCouponId() { return couponId; }
    public void setCouponId(Long couponId) { this.couponId = couponId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void cancel() {
        throw new UnsupportedOperationException("cancel not implemented");
    }
    public Boolean pay(String paymentRef) {
        throw new UnsupportedOperationException("pay not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal calculateTotal() {
        throw new UnsupportedOperationException("calculateTotal not implemented");
    }
    public java.math.BigDecimal applyDiscount(Integer percent) {
        throw new UnsupportedOperationException("applyDiscount not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void refund() {
        throw new UnsupportedOperationException("refund not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void notifyShipped() {
        throw new UnsupportedOperationException("notifyShipped not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Order total must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isTotalNotNegativeValid() {
        return (getTotal() == null || getTotal().compareTo(new java.math.BigDecimal("0")) >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Discount applied cannot exceed order total")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDiscountNotExceedTotalValid() {
        return (getDiscountApplied() == null || (getTotal() != null && getDiscountApplied().compareTo(getTotal()) <= 0));
    }
}
