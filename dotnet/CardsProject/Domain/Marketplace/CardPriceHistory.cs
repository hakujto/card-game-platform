using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public class CardPriceHistory : IValidatableObject
{
    public int Id { get; set; }

    public DateOnly? PriceDate { get; set; } = null;
    public decimal AvgPrice { get; set; } = 0.00m;
    public decimal MinPrice { get; set; } = 0.00m;
    public decimal MaxPrice { get; set; } = 0.00m;
    public int Volume { get; set; } = 0;
    public bool Foil { get; set; } = false;

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public decimal PriceChangePercent(decimal previousAvg)
    {
        throw new NotImplementedException("price_change_percent not implemented");
    }

    public bool IsPriceSpike(int thresholdPercent)
    {
        throw new NotImplementedException("is_price_spike not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (MinPrice <= AvgPrice && AvgPrice <= MaxPrice) ))
            yield return new ValidationResult("min_price <= avg_price <= max_price must hold", new[] { nameof(Id) });
        if (!( Volume >= 0 ))
            yield return new ValidationResult("Price history volume must not be negative", new[] { nameof(Id) });
        if (!( MinPrice >= 0m ))
            yield return new ValidationResult("Prices must not be negative", new[] { nameof(Id) });
    }
}
