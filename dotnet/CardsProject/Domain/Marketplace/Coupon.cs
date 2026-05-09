namespace CardsProject.Domain.Marketplace;

public enum CouponDiscountTypeType
{
    Percent,
    Fixed
}

public class Coupon
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
}
