package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.OrderItem;
import cardsproject.repository.marketplace.OrderItemRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class OrderItemService {

    private final OrderItemRepository repository;

    public OrderItemService(OrderItemRepository repository) {
        this.repository = repository;
    }

    public List<OrderItem> findAll() {
        return repository.findAll();
    }

    public Optional<OrderItem> findById(Long id) {
        return repository.findById(id);
    }

    public OrderItem save(OrderItem entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(OrderItem entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("quantity") && patch.get("quantity") != null) entity.setQuantity(Integer.valueOf(patch.get("quantity").toString()));
        if (patch.containsKey("priceAtPurchase") && patch.get("priceAtPurchase") != null) entity.setPriceAtPurchase(new java.math.BigDecimal(patch.get("priceAtPurchase").toString()));
        if (patch.containsKey("foil") && patch.get("foil") != null) entity.setFoil(Boolean.valueOf(patch.get("foil").toString()));
        if (patch.containsKey("orderId") && patch.get("orderId") != null) entity.setOrderId(Long.valueOf(patch.get("orderId").toString()));
        if (patch.containsKey("productId") && patch.get("productId") != null) entity.setProductId(Long.valueOf(patch.get("productId").toString()));
    }

    public java.math.BigDecimal lineTotal(Long id) {
        OrderItem entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("OrderItem not found: " + id));
        java.math.BigDecimal result = entity.lineTotal();
        repository.save(entity);
        return result;
    }
}
