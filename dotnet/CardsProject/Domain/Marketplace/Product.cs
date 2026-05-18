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
        throw new NotImplementedException("activate not implemented");
    }

    public void Deactivate()
    {
        throw new NotImplementedException("deactivate not implemented");
    }

    public decimal ApplyDiscount(int percent)
    {
        throw new NotImplementedException("apply_discount not implemented");
    }

    public void Restock(int quantity)
    {
        throw new NotImplementedException("restock not implemented");
    }

    public decimal EffectivePrice()
    {
        throw new NotImplementedException("effective_price not implemented");
    }

    public bool IsInStock()
    {
        throw new NotImplementedException("is_in_stock not implemented");
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
