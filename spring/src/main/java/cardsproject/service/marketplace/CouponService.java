package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Coupon;
import cardsproject.repository.marketplace.CouponRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.CouponDiscountTypeType;

@Service
public class CouponService {

    private final CouponRepository repository;

    public CouponService(CouponRepository repository) {
        this.repository = repository;
    }

    public List<Coupon> findAll() {
        return repository.findAll();
    }

    public List<Coupon> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getCode() != null && e.getCode().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Coupon> findById(Long id) {
        return repository.findById(id);
    }

    public Coupon save(Coupon entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Coupon entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("code") && patch.get("code") != null) entity.setCode(patch.get("code").toString());
        if (patch.containsKey("discountType")) entity.setDiscountType(CouponDiscountTypeType.valueOf(patch.get("discountType").toString()));
        if (patch.containsKey("discountValue") && patch.get("discountValue") != null) entity.setDiscountValue(new java.math.BigDecimal(patch.get("discountValue").toString()));
        if (patch.containsKey("minOrderValue") && patch.get("minOrderValue") != null) entity.setMinOrderValue(new java.math.BigDecimal(patch.get("minOrderValue").toString()));
        if (patch.containsKey("maxUses") && patch.get("maxUses") != null) entity.setMaxUses(Integer.valueOf(patch.get("maxUses").toString()));
        if (patch.containsKey("usesCount") && patch.get("usesCount") != null) entity.setUsesCount(Integer.valueOf(patch.get("usesCount").toString()));
        if (patch.containsKey("validFrom") && patch.get("validFrom") != null) entity.setValidFrom(java.time.LocalDateTime.parse(patch.get("validFrom").toString()));
        if (patch.containsKey("validUntil") && patch.get("validUntil") != null) entity.setValidUntil(java.time.LocalDateTime.parse(patch.get("validUntil").toString()));
        if (patch.containsKey("isActive") && patch.get("isActive") != null) entity.setIsActive(Boolean.valueOf(patch.get("isActive").toString()));
    }
    private void validate(Coupon entity) {
        if (CouponDiscountTypeType.PERCENT.equals(entity.getDiscountType()) && !((entity.getDiscountValue() == null || (entity.getDiscountValue().compareTo(new java.math.BigDecimal("1")) >= 0 && entity.getDiscountValue().compareTo(new java.math.BigDecimal("100")) <= 0)))) throw new IllegalStateException("Percent discount must be between 1 and 100");
        if (entity.getMaxUses() != null && !((entity.getUsesCount() == null || (entity.getMaxUses() != null && entity.getUsesCount() <= entity.getMaxUses())))) throw new IllegalStateException("Coupon uses count cannot exceed max_uses");
    }

    public Boolean isValid(Long id) {
        Coupon entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Coupon not found: " + id));
        Boolean result = entity.isValid();
        repository.save(entity);
        return result;
    }

    public Boolean isApplicableToOrder(Long id, java.math.BigDecimal orderTotal) {
        Coupon entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Coupon not found: " + id));
        Boolean result = entity.isApplicableToOrder(orderTotal);
        repository.save(entity);
        return result;
    }

    public void redeem(Long id) {
        Coupon entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Coupon not found: " + id));
        entity.redeem();
        repository.save(entity);
    }

    public void deactivate(Long id) {
        Coupon entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Coupon not found: " + id));
        entity.deactivate();
        repository.save(entity);
    }
}
