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
        throw new NotImplementedException("is_valid not implemented");
    }

    public bool IsApplicableToOrder(decimal orderTotal)
    {
        throw new NotImplementedException("is_applicable_to_order not implemented");
    }

    public void Redeem()
    {
        throw new NotImplementedException("redeem not implemented");
    }

    public void Deactivate()
    {
        throw new NotImplementedException("deactivate not implemented");
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
