package cardsproject.domain.marketplace.events;

import org.springframework.context.ApplicationEvent;
import java.time.LocalDateTime;

public class OrderRefunded extends ApplicationEvent {

    private final Integer orderId;
    private final LocalDateTime refundedAt;

    public OrderRefunded(Object source, Integer orderId, LocalDateTime refundedAt) {
        super(source);
        this.orderId = orderId;
        this.refundedAt = refundedAt;
    }

    public Integer getOrderId() { return orderId; }

    public LocalDateTime getRefundedAt() { return refundedAt; }
}
