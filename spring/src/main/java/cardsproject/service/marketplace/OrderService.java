package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Order;
import cardsproject.repository.marketplace.OrderRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.OrderStatusType;
import cardsproject.domain.marketplace.OrderPaymentMethodType;

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
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Order entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("status")) entity.setStatus(OrderStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("total") && patch.get("total") != null) entity.setTotal(new java.math.BigDecimal(patch.get("total").toString()));
        if (patch.containsKey("discountApplied") && patch.get("discountApplied") != null) entity.setDiscountApplied(new java.math.BigDecimal(patch.get("discountApplied").toString()));
        if (patch.containsKey("currency") && patch.get("currency") != null) entity.setCurrency(patch.get("currency").toString());
        if (patch.containsKey("paymentMethod")) entity.setPaymentMethod(OrderPaymentMethodType.valueOf(patch.get("paymentMethod").toString()));
        if (patch.containsKey("paymentReference") && patch.get("paymentReference") != null) entity.setPaymentReference(patch.get("paymentReference").toString());
        if (patch.containsKey("shippingAddress") && patch.get("shippingAddress") != null) entity.setShippingAddress(patch.get("shippingAddress").toString());
        if (patch.containsKey("trackingNumber") && patch.get("trackingNumber") != null) entity.setTrackingNumber(patch.get("trackingNumber").toString());
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("paidAt") && patch.get("paidAt") != null) entity.setPaidAt(java.time.LocalDateTime.parse(patch.get("paidAt").toString()));
        if (patch.containsKey("shippedAt") && patch.get("shippedAt") != null) entity.setShippedAt(java.time.LocalDateTime.parse(patch.get("shippedAt").toString()));
        if (patch.containsKey("playerId") && patch.get("playerId") != null) entity.setPlayerId(Long.valueOf(patch.get("playerId").toString()));
        if (patch.containsKey("couponId") && patch.get("couponId") != null) entity.setCouponId(Long.valueOf(patch.get("couponId").toString()));
    }
    private void validate(Order entity) {
        if (OrderStatusType.PAID.equals(entity.getStatus()) && entity.getPaidAt() == null) throw new IllegalStateException("Paid order must have paid_at set");
        if (OrderStatusType.SHIPPED.equals(entity.getStatus()) && entity.getTrackingNumber() == null) throw new IllegalStateException("Shipped order must have a tracking number");
        if (entity.getShippedAt() != null && !(OrderStatusType.SHIPPED.equals(entity.getStatus()))) throw new IllegalStateException("shipped_at_requires_shipped_status");
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
        if (!(OrderStatusType.PENDING.equals(entity.getStatus())))
            throw new IllegalStateException("Guard condition not met for pay");
        Boolean result = entity.pay(paymentRef);
        repository.save(entity);
        return result;
    }

    public Boolean processPayment(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        Boolean result = entity.processPayment();
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

    // triggered by @on(status = Shipped)
    public void setStatus(Long id, OrderStatusType status) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.setStatus(status);
        if (status == OrderStatusType.SHIPPED) {
            entity.notifyShipped();
        }
        repository.save(entity);
    }

    public Order transitionPendingToPaid(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.PAID);
        if (entity.getPaymentMethod() == null) {
            throw new IllegalArgumentException("payment_method is required for Pending -> Paid");
        }
        entity.setStatus(OrderStatusType.PAID);
        entity.processPayment(); // @after
        return repository.save(entity);
    }

    public Order transitionPaidToProcessing(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.PROCESSING);
        entity.setStatus(OrderStatusType.PROCESSING);
        return repository.save(entity);
    }

    public Order transitionProcessingToShipped(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.SHIPPED);
        if (entity.getTrackingNumber() == null) {
            throw new IllegalArgumentException("tracking_number is required for Processing -> Shipped");
        }
        entity.setStatus(OrderStatusType.SHIPPED);
        entity.notifyShipped(); // @after
        return repository.save(entity);
    }

    public Order transitionShippedToCompleted(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.COMPLETED);
        entity.setStatus(OrderStatusType.COMPLETED);
        return repository.save(entity);
    }

    public Order transitionPendingToCancelled(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.CANCELLED);
        entity.setStatus(OrderStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public Order transitionPaidToCancelled(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.CANCELLED);
        entity.setStatus(OrderStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public Order transitionCompletedToRefunded(Long id) {
        Order entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Order not found: " + id));
        entity.assertTransition(OrderStatusType.REFUNDED);
        entity.setStatus(OrderStatusType.REFUNDED);
        entity.refund(); // @after
        return repository.save(entity);
    }

    public void transitionRefundedToCompleted(Long id) {
        throw new IllegalStateException("Transition Refunded -> Completed is not allowed");
    }

    public void transitionCompletedToCancelled(Long id) {
        throw new IllegalStateException("Transition Completed -> Cancelled is not allowed");
    }
}
