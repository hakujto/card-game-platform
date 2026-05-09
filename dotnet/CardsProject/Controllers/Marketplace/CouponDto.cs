namespace CardsProject.Controllers.Marketplace;

public class CouponDto
{
    public string? Code { get; set; }
    public string? DiscountType { get; set; }
    public decimal? DiscountValue { get; set; }
    public decimal? MinOrderValue { get; set; }
    public int? MaxUses { get; set; }
    public int? UsesCount { get; set; }
    public DateTime? ValidFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public bool? IsActive { get; set; }
}
