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
    private void validate(Coupon entity) {
        if (CouponDiscountTypeType.PERCENT.equals(entity.getDiscountType()) && !((entity.getDiscountValue() == null || (entity.getDiscountValue().compareTo(new java.math.BigDecimal("1")) >= 0 && entity.getDiscountValue().compareTo(new java.math.BigDecimal("100")) <= 0)))) throw new IllegalStateException("Percent discount must be between 1 and 100");
        if (entity.getMaxUses() != null && !((entity.getUsesCount() == null || entity.getUsesCount() <= entity.getMaxUses()))) throw new IllegalStateException("Coupon uses count cannot exceed max_uses");
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
