package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Order;
import cardsproject.repository.marketplace.OrderRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {

    private final OrderRepository repository;

    public OrderService(OrderRepository repository) {
        this.repository = repository;
    }

    public List<Order> findAll() {
        return repository.findAll();
    }

    public Optional<Order> findById(Long id) {
        return repository.findById(id);
    }

    public Order save(Order entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void cancel(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.cancel();
        repository.save(entity);
    }

    public Boolean pay(Long id, String paymentRef) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        Boolean result = entity.pay(paymentRef);
        repository.save(entity);
        return result;
    }

    public java.math.BigDecimal calculateTotal(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        java.math.BigDecimal result = entity.calculateTotal();
        repository.save(entity);
        return result;
    }

    public java.math.BigDecimal applyDiscount(Long id, Integer percent) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        java.math.BigDecimal result = entity.applyDiscount(percent);
        repository.save(entity);
        return result;
    }

    public void refund(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.refund();
        repository.save(entity);
    }
}
