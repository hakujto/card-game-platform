package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "trade_disputes")
public class TradeDispute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TradeDisputeReasonType reason;
    private String description = "";
    @Enumerated(EnumType.STRING)
    private TradeDisputeStatusType status;
    private String resolution;
    private LocalDateTime openedAt;
    private LocalDateTime resolvedAt;

    @Column(name = "transaction_id")
    private Long transactionId;
    @Column(name = "opened_by_id")
    private Long openedById;
    @Column(name = "resolved_by_id")
    private Long resolvedById;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TradeDisputeReasonType getReason() { return reason; }
    public void setReason(TradeDisputeReasonType reason) { this.reason = reason; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public TradeDisputeStatusType getStatus() { return status; }
    public void setStatus(TradeDisputeStatusType status) { this.status = status; }
    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }
    public LocalDateTime getOpenedAt() { return openedAt; }
    public void setOpenedAt(LocalDateTime openedAt) { this.openedAt = openedAt; }
    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }
    public Long getOpenedById() { return openedById; }
    public void setOpenedById(Long openedById) { this.openedById = openedById; }
    public Long getResolvedById() { return resolvedById; }
    public void setResolvedById(Long resolvedById) { this.resolvedById = resolvedById; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void escalate() {
        throw new UnsupportedOperationException("escalate not implemented");
    }
    public void resolve(String resolutionText) {
        throw new UnsupportedOperationException("resolve not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void review() {
        throw new UnsupportedOperationException("review not implemented");
    }
}
