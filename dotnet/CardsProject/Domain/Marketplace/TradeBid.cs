using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public class TradeBid : IValidatableObject
{
    public int Id { get; set; }

    public decimal Amount { get; set; } = 0.00m;
    public DateTime? PlacedAt { get; set; } = null;
    public bool IsWinning { get; set; } = false;

    public int? ListingId { get; set; }
    [ForeignKey(nameof(ListingId))]
    public Tradelisting? Listing { get; set; }
    public int? BidderId { get; set; }
    [ForeignKey(nameof(BidderId))]
    public Player? Bidder { get; set; }

    // Business operations

    public bool OutbidBy(decimal newAmount)
    {
        throw new NotImplementedException("outbid_by not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Amount > 0m ))
            yield return new ValidationResult("Bid amount must be greater than zero", new[] { nameof(Id) });
    }
}
