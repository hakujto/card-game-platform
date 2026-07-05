package cardsproject.domain.marketplace.events;

import org.springframework.context.ApplicationEvent;
import java.time.LocalDateTime;

public class OrderShipped extends ApplicationEvent {

    private final Integer orderId;
    private final String trackingNumber;
    private final LocalDateTime shippedAt;

    public OrderShipped(Object source, Integer orderId, String trackingNumber, LocalDateTime shippedAt) {
        super(source);
        this.orderId = orderId;
        this.trackingNumber = trackingNumber;
        this.shippedAt = shippedAt;
    }

    public Integer getOrderId() { return orderId; }

    public String getTrackingNumber() { return trackingNumber; }

    public LocalDateTime getShippedAt() { return shippedAt; }
}
