using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public enum CouponDiscountTypeType
{
    Percent,
    Fixed
}

public class Coupon : IValidatableObject
{
    public int Id { get; set; }

    public string Code { get; set; } = "";
    public CouponDiscountTypeType DiscountType { get; set; }
    public decimal DiscountValue { get; set; } = 0.00m;
    public decimal MinOrderValue { get; set; } = 0.00m;
    public int? MaxUses { get; set; } = null;
    public int UsesCount { get; set; } = 0;
    public DateTime? ValidFrom { get; set; } = null;
    public DateTime? ValidUntil { get; set; } = null;
    public bool IsActive { get; set; } = true;

    // Business operations

    public bool IsValid()
    {
        // TODO: implement is_valid
        return default;
    }

    public bool IsApplicableToOrder(decimal orderTotal)
    {
        // TODO: implement is_applicable_to_order
        return default;
    }

    public void Redeem()
    {
        // TODO: implement redeem
    }

    public void Deactivate()
    {
        // TODO: implement deactivate
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (ValidUntil == null || (ValidFrom != null && ValidUntil > ValidFrom)) ))
            yield return new ValidationResult("Coupon expiry must be after its start date", new[] { nameof(Id) });
        if (!( DiscountValue > 0m ))
            yield return new ValidationResult("Discount value must be greater than zero", new[] { nameof(Id) });
    }
}
