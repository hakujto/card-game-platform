package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "coupons")
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String code = "";
    @Enumerated(EnumType.STRING)
    private CouponDiscountTypeType discountType;
    private BigDecimal discountValue = BigDecimal.ZERO;
    private BigDecimal minOrderValue = new BigDecimal("0");
    private Integer maxUses;
    private Integer usesCount = 0;
    private LocalDateTime validFrom;
    private LocalDateTime validUntil;
    private Boolean isActive = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public CouponDiscountTypeType getDiscountType() { return discountType; }
    public void setDiscountType(CouponDiscountTypeType discountType) { this.discountType = discountType; }
    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }
    public BigDecimal getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(BigDecimal minOrderValue) { this.minOrderValue = minOrderValue; }
    public Integer getMaxUses() { return maxUses; }
    public void setMaxUses(Integer maxUses) { this.maxUses = maxUses; }
    public Integer getUsesCount() { return usesCount; }
    public void setUsesCount(Integer usesCount) { this.usesCount = usesCount; }
    public LocalDateTime getValidFrom() { return validFrom; }
    public void setValidFrom(LocalDateTime validFrom) { this.validFrom = validFrom; }
    public LocalDateTime getValidUntil() { return validUntil; }
    public void setValidUntil(LocalDateTime validUntil) { this.validUntil = validUntil; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isValid() {
        throw new UnsupportedOperationException("isValid not implemented");
    }
    public Boolean isApplicableToOrder(java.math.BigDecimal orderTotal) {
        throw new UnsupportedOperationException("isApplicableToOrder not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void redeem() {
        throw new UnsupportedOperationException("redeem not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void deactivate() {
        throw new UnsupportedOperationException("deactivate not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Coupon expiry must be after its start date")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isValidUntilAfterValidFromValid() {
        return (getValidUntil() == null || (getValidFrom() != null && getValidUntil().isAfter(getValidFrom())));
    }
    @jakarta.validation.constraints.AssertTrue(message = "Discount value must be greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDiscountValuePositiveValid() {
        return (getDiscountValue() == null || getDiscountValue().compareTo(new java.math.BigDecimal("0")) > 0);
    }
}
