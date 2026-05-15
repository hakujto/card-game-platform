using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public enum TradeTransactionStatusType
{
    Pending,
    Completed,
    Disputed,
    Refunded
}

public class TradeTransaction : IValidatableObject
{
    public int Id { get; set; }

    public decimal FinalPrice { get; set; } = 0.00m;
    public decimal PlatformFee { get; set; } = 0.00m;
    public TradeTransactionStatusType Status { get; set; }
    public DateTime? CompletedAt { get; set; } = null;

    public int? ListingId { get; set; }
    [ForeignKey(nameof(ListingId))]
    public Tradelisting? Listing { get; set; }
    public int? BuyerId { get; set; }
    [ForeignKey(nameof(BuyerId))]
    public Player? Buyer { get; set; }
    public int? SellerId { get; set; }
    [ForeignKey(nameof(SellerId))]
    public Player? Seller { get; set; }

    // Business operations

    public void Complete()
    {
        throw new NotImplementedException("complete not implemented");
    }

    public void Refund()
    {
        throw new NotImplementedException("refund not implemented");
    }

    public void OpenDispute(string reason)
    {
        throw new NotImplementedException("open_dispute not implemented");
    }

    public decimal SellerNet()
    {
        throw new NotImplementedException("seller_net not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (FinalPrice != null && PlatformFee <= FinalPrice) ))
            yield return new ValidationResult("Platform fee cannot exceed the final price", new[] { nameof(Id) });
        if (!( PlatformFee >= 0m ))
            yield return new ValidationResult("Platform fee must not be negative", new[] { nameof(Id) });
    }
}
