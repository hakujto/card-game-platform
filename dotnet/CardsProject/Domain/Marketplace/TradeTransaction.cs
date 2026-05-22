using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

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
    [JsonPropertyName("completedAt")]
    public DateTime? CompletedAt { get; set; } = null;

    public int? ListingId { get; set; }
    [ForeignKey(nameof(ListingId))]
    public TradeListing? Listing { get; set; }
    public int? BuyerId { get; set; }
    [ForeignKey(nameof(BuyerId))]
    public Player? Buyer { get; set; }
    public int? SellerId { get; set; }
    [ForeignKey(nameof(SellerId))]
    public Player? Seller { get; set; }

    // Business operations

    public void Complete()
    {
        // TODO: implement complete
    }

    public void Refund()
    {
        // TODO: implement refund
    }

    public void OpenDispute(string reason)
    {
        // TODO: implement open_dispute
    }

    public decimal SellerNet()
    {
        // TODO: implement seller_net
        return default;
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( PlatformFee <= FinalPrice ))
            yield return new ValidationResult("Platform fee cannot exceed the final price", new[] { nameof(Id) });
        if (!( PlatformFee >= 0m ))
            yield return new ValidationResult("Platform fee must not be negative", new[] { nameof(Id) });
        if (!( FinalPrice > 0m ))
            yield return new ValidationResult("Transaction final price must be greater than zero", new[] { nameof(Id) });
    }
}
