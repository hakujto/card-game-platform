package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantity = 0;
    private BigDecimal priceAtPurchase = BigDecimal.ZERO;
    private Boolean foil = false;

    @Column(name = "order_id")
    private Long orderId;
    @Column(name = "product_id")
    private Long productId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getPriceAtPurchase() { return priceAtPurchase; }
    public void setPriceAtPurchase(BigDecimal priceAtPurchase) { this.priceAtPurchase = priceAtPurchase; }
    public Boolean getFoil() { return foil; }
    public void setFoil(Boolean foil) { this.foil = foil; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal lineTotal() {
        throw new UnsupportedOperationException("lineTotal not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Order item quantity must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isQuantityPositiveValid() {
        return (getQuantity() == null || getQuantity() > 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Price at purchase must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPriceNotNegativeValid() {
        return (getPriceAtPurchase() == null || getPriceAtPurchase().compareTo(new java.math.BigDecimal("0")) >= 0);
    }
}
