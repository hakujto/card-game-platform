using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum TradeDisputeReasonType
{
    ItemNotReceived,
    ItemNotAsDescribed,
    FraudSuspected,
    Other
}

public enum TradeDisputeStatusType
{
    Open,
    UnderReview,
    Resolved,
    Escalated
}

public class TradeDispute
{
    public int Id { get; set; }

    public TradeDisputeReasonType Reason { get; set; }
    public string Description { get; set; } = "";
    public TradeDisputeStatusType Status { get; set; }
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
}
