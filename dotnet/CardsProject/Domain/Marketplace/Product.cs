using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public enum ProductProductTypeType
{
    SingleCard,
    BoosterPack,
    Bundle,
    PreconstructedDeck,
    Accessory
}

public class Product : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public ProductProductTypeType ProductType { get; set; }
    public decimal Price { get; set; } = 0.00m;
    public int Stock { get; set; } = 0;
    public bool Active { get; set; } = true;
    public int DiscountPercent { get; set; } = 0;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public bool Featured { get; set; } = false;

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
    public int? CardSetId { get; set; }
    [ForeignKey(nameof(CardSetId))]
    public CardSet? CardSet { get; set; }

    // Business operations

    public void Activate()
    {
        // TODO: implement activate
    }

    public void Deactivate()
    {
        // TODO: implement deactivate
    }

    public decimal ApplyDiscount(int percent)
    {
        // TODO: implement apply_discount
        return default;
    }

    public void Restock(int quantity)
    {
        // TODO: implement restock
    }

    public decimal EffectivePrice()
    {
        // TODO: implement effective_price
        return default;
    }

    public bool IsInStock()
    {
        // TODO: implement is_in_stock
        return default;
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Price > 0m ))
            yield return new ValidationResult("Product price must be greater than zero", new[] { nameof(Id) });
        if (!( Stock >= 0 ))
            yield return new ValidationResult("Product stock must not be negative", new[] { nameof(Id) });
        if (!( DiscountPercent >= 0 && DiscountPercent <= 100 ))
            yield return new ValidationResult("Product discount percent must be between 0 and 100", new[] { nameof(Id) });
    }
}
