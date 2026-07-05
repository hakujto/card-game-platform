package cardsproject.domain.marketplace.events;

import org.springframework.context.ApplicationEvent;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrderPaid extends ApplicationEvent {

    private final Integer orderId;
    private final Integer playerId;
    private final BigDecimal total;
    private final String paymentMethod;
    private final LocalDateTime paidAt;

    public OrderPaid(Object source, Integer orderId, Integer playerId, BigDecimal total, String paymentMethod, LocalDateTime paidAt) {
        super(source);
        this.orderId = orderId;
        this.playerId = playerId;
        this.total = total;
        this.paymentMethod = paymentMethod;
        this.paidAt = paidAt;
    }

    public Integer getOrderId() { return orderId; }

    public Integer getPlayerId() { return playerId; }

    public BigDecimal getTotal() { return total; }

    public String getPaymentMethod() { return paymentMethod; }

    public LocalDateTime getPaidAt() { return paidAt; }
}
