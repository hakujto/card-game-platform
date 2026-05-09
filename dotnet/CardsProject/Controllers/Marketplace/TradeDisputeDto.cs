namespace CardsProject.Controllers.Marketplace;

public class TradeDisputeDto
{
    public string? Reason { get; set; }
    public string? Description { get; set; }
    public string? Status { get; set; }
    public string? Resolution { get; set; }
    public DateTime? OpenedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
    public int? TransactionId { get; set; }
    public int? OpenedById { get; set; }
    public int? ResolvedById { get; set; }
}
