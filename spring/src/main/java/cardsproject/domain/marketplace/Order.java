package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import jakarta.validation.constraints.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

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
    @Pattern(regexp = "[A-Z]{3}")
    private String currency = "USD";
    @Enumerated(EnumType.STRING)
    private OrderPaymentMethodType paymentMethod;
    private String paymentReference;
    private String shippingAddress;
    private String trackingNumber;
    private LocalDateTime createdAt;
    private LocalDateTime paidAt;
    private LocalDateTime shippedAt;

    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=orders, via=players
    @Column(name = "player_id")
    private Long playerId;
    // @ManyToOne -> Coupon, onDelete=SET_NULL, relatedName=orders
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
    @JsonIgnore
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    @JsonProperty("paidAt")
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
    @JsonProperty("shippedAt")
    public LocalDateTime getShippedAt() { return shippedAt; }
    public void setShippedAt(LocalDateTime shippedAt) { this.shippedAt = shippedAt; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
    public Long getCouponId() { return couponId; }
    public void setCouponId(Long couponId) { this.couponId = couponId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void cancel() {
        // TODO: implement cancel
    }
    public Boolean pay(String paymentRef) {
        // TODO: implement pay
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean processPayment() {
        // TODO: implement processPayment
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal calculateTotal() {
        // TODO: implement calculateTotal
        return null;
    }
    public java.math.BigDecimal applyDiscount(Integer percent) {
        // TODO: implement applyDiscount
        return null;
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void refund() {
        // TODO: implement refund
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void notifyShipped() {
        // TODO: implement notifyShipped
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
    @jakarta.validation.constraints.AssertTrue(message = "tracking_number is required")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isTrackingNumberRequiredWhenValid() {
        return !(OrderStatusType.SHIPPED.equals(getStatus())) || getTrackingNumber() != null;
    }
    @jakarta.validation.constraints.AssertTrue(message = "paid_at is required")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPaidAtRequiredWhenValid() {
        return !(OrderStatusType.PAID.equals(getStatus())) || getPaidAt() != null;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<OrderStatusType, java.util.List<OrderStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(OrderStatusType.PENDING, java.util.List.of(OrderStatusType.PAID, OrderStatusType.CANCELLED)),
        java.util.Map.entry(OrderStatusType.PAID, java.util.List.of(OrderStatusType.PROCESSING, OrderStatusType.CANCELLED)),
        java.util.Map.entry(OrderStatusType.PROCESSING, java.util.List.of(OrderStatusType.SHIPPED)),
        java.util.Map.entry(OrderStatusType.SHIPPED, java.util.List.of(OrderStatusType.COMPLETED)),
        java.util.Map.entry(OrderStatusType.COMPLETED, java.util.List.of(OrderStatusType.REFUNDED))
        );

    public void assertTransition(OrderStatusType to) {
        java.util.List<OrderStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    @PrePersist
    public void assignCurrencyDefault() {
        // TODO: implement assign_currency_default
    }
    @PostUpdate
    public void notifyStatusChange() {
        // TODO: implement notify_status_change
    }
}
