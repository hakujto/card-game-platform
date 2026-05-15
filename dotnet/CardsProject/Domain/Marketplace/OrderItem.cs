using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public class OrderItem : IValidatableObject
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 0;
    public decimal PriceAtPurchase { get; set; } = 0.00m;
    public bool Foil { get; set; } = false;

    public int? OrderId { get; set; }
    [ForeignKey(nameof(OrderId))]
    public Order? Order { get; set; }
    public int? ProductId { get; set; }
    [ForeignKey(nameof(ProductId))]
    public Product? Product { get; set; }

    // Business operations

    public decimal LineTotal()
    {
        throw new NotImplementedException("line_total not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Quantity > 0 ))
            yield return new ValidationResult("Order item quantity must be greater than zero", new[] { nameof(Id) });
        if (!( PriceAtPurchase >= 0m ))
            yield return new ValidationResult("Price at purchase must not be negative", new[] { nameof(Id) });
    }
}
