using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum TradeDisputeStatusType
{
    Open,
    UnderReview,
    Resolved,
    Escalated
}

public enum TradeDisputeReasonType
{
    ItemNotReceived,
    ItemNotAsDescribed,
    FraudSuspected,
    Other
}

public class TradeDispute
{
    public int Id { get; set; }

    public TradeDisputeStatusType Status { get; set; }
    public TradeDisputeReasonType Reason { get; set; }
    public string Description { get; set; } = "";
    public string? Resolution { get; set; }
    public DateTime? OpenedAt { get; set; } = null;
    public DateTime? ResolvedAt { get; set; } = null;

    public int? TransactionId { get; set; }
    [ForeignKey(nameof(TransactionId))]
    public TradeTransaction? Transaction { get; set; }
    public int? OpenedById { get; set; }
    [ForeignKey(nameof(OpenedById))]
    public Player? OpenedBy { get; set; }
    public int? ResolvedById { get; set; }
    [ForeignKey(nameof(ResolvedById))]
    public Player? ResolvedBy { get; set; }

    // Business operations

    public void Escalate()
    {
        // TODO: implement escalate
    }

    public void Resolve(string resolutionText)
    {
        // TODO: implement resolve
    }

    public void CloseResolved()
    {
        // TODO: implement close_resolved
    }

    public void Review()
    {
        // TODO: implement review
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<TradeDisputeStatusType, TradeDisputeStatusType[]> AllowedTransitions = new()
    {
        [TradeDisputeStatusType.Open] = new[] { TradeDisputeStatusType.UnderReview },
        [TradeDisputeStatusType.UnderReview] = new[] { TradeDisputeStatusType.Resolved, TradeDisputeStatusType.Escalated },
        [TradeDisputeStatusType.Escalated] = new[] { TradeDisputeStatusType.Resolved }
    };

    public void AssertTransition(TradeDisputeStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
    }
}
