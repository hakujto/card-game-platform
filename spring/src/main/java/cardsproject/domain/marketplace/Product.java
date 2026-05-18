package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    @Enumerated(EnumType.STRING)
    private ProductProductTypeType productType;
    private BigDecimal price = BigDecimal.ZERO;
    private Integer stock = 0;
    private Boolean active = true;
    private Integer discountPercent = 0;
    private String description;
    private String imageUrl;
    private Boolean featured = false;

    @Column(name = "card_id")
    private Long cardId;
    @Column(name = "card_set_id")
    private Long cardSetId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public ProductProductTypeType getProductType() { return productType; }
    public void setProductType(ProductProductTypeType productType) { this.productType = productType; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public Integer getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Integer discountPercent) { this.discountPercent = discountPercent; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public Boolean getFeatured() { return featured; }
    public void setFeatured(Boolean featured) { this.featured = featured; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
    public Long getCardSetId() { return cardSetId; }
    public void setCardSetId(Long cardSetId) { this.cardSetId = cardSetId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void activate() {
        throw new UnsupportedOperationException("activate not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void deactivate() {
        throw new UnsupportedOperationException("deactivate not implemented");
    }
    public java.math.BigDecimal applyDiscount(Integer percent) {
        throw new UnsupportedOperationException("applyDiscount not implemented");
    }
    public void restock(Integer quantity) {
        throw new UnsupportedOperationException("restock not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public java.math.BigDecimal effectivePrice() {
        throw new UnsupportedOperationException("effectivePrice not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isInStock() {
        throw new UnsupportedOperationException("isInStock not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Product price must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isPricePositiveValid() {
        return (getPrice() == null || getPrice().compareTo(new java.math.BigDecimal("0")) > 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Product stock must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isStockNotNegativeValid() {
        return (getStock() == null || getStock() >= 0);
    }
    @jakarta.validation.constraints.AssertTrue(message = "Product discount percent must be between 0 and 100")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDiscountPercentRangeValid() {
        return (getDiscountPercent() == null || (getDiscountPercent() >= 0 && getDiscountPercent() <= 100));
    }
}
