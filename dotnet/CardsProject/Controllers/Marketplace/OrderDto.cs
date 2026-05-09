namespace CardsProject.Controllers.Marketplace;

public class OrderDto
{
    public string? Status { get; set; }
    public decimal? Total { get; set; }
    public decimal? DiscountApplied { get; set; }
    public string? Currency { get; set; }
    public string? PaymentMethod { get; set; }
    public string? PaymentReference { get; set; }
    public string? ShippingAddress { get; set; }
    public string? TrackingNumber { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? ShippedAt { get; set; }
    public int? PlayerId { get; set; }
    public int? ItemsId { get; set; }
    public int? CouponId { get; set; }
}
