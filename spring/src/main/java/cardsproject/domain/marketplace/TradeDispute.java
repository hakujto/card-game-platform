package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "trade_disputes")
public class TradeDispute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TradeDisputeStatusType status;
    @Enumerated(EnumType.STRING)
    private TradeDisputeReasonType reason;
    private String description = "";
    private String resolution;
    private LocalDateTime openedAt;
    private LocalDateTime resolvedAt;

    // @OneToOne -> TradeTransaction, onDelete=CASCADE, relatedName=dispute
    @Column(name = "transaction_id")
    private Long transactionId;
    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=disputes_opened, via=players
    @Column(name = "opened_by_id")
    private Long openedById;
    // @ManyToOne -> Player, onDelete=SET_NULL, relatedName=disputes_resolved, via=players
    @Column(name = "resolved_by_id")
    private Long resolvedById;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TradeDisputeStatusType getStatus() { return status; }
    public void setStatus(TradeDisputeStatusType status) { this.status = status; }
    public TradeDisputeReasonType getReason() { return reason; }
    public void setReason(TradeDisputeReasonType reason) { this.reason = reason; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }
    @JsonProperty("openedAt")
    public LocalDateTime getOpenedAt() { return openedAt; }
    public void setOpenedAt(LocalDateTime openedAt) { this.openedAt = openedAt; }
    @JsonProperty("resolvedAt")
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
        // TODO: implement escalate
    }
    public void resolve(String resolutionText) {
        // TODO: implement resolve
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void closeResolved() {
        // TODO: implement closeResolved
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void review() {
        // TODO: implement review
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<TradeDisputeStatusType, java.util.List<TradeDisputeStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(TradeDisputeStatusType.OPEN, java.util.List.of(TradeDisputeStatusType.UNDERREVIEW)),
        java.util.Map.entry(TradeDisputeStatusType.UNDERREVIEW, java.util.List.of(TradeDisputeStatusType.RESOLVED, TradeDisputeStatusType.ESCALATED)),
        java.util.Map.entry(TradeDisputeStatusType.ESCALATED, java.util.List.of(TradeDisputeStatusType.RESOLVED))
        );

    public void assertTransition(TradeDisputeStatusType to) {
        java.util.List<TradeDisputeStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
