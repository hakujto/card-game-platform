package cardsproject.domain.marketplace.events;

import org.springframework.context.ApplicationEvent;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransactionCompleted extends ApplicationEvent {

    private final Integer transactionId;
    private final Integer buyerId;
    private final Integer sellerId;
    private final BigDecimal finalPrice;
    private final LocalDateTime completedAt;

    public TransactionCompleted(Object source, Integer transactionId, Integer buyerId, Integer sellerId, BigDecimal finalPrice, LocalDateTime completedAt) {
        super(source);
        this.transactionId = transactionId;
        this.buyerId = buyerId;
        this.sellerId = sellerId;
        this.finalPrice = finalPrice;
        this.completedAt = completedAt;
    }

    public Integer getTransactionId() { return transactionId; }

    public Integer getBuyerId() { return buyerId; }

    public Integer getSellerId() { return sellerId; }

    public BigDecimal getFinalPrice() { return finalPrice; }

    public LocalDateTime getCompletedAt() { return completedAt; }
}
