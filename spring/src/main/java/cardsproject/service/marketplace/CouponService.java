package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Coupon;
import cardsproject.repository.marketplace.CouponRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
