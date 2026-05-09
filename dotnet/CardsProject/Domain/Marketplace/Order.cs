using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum OrderStatusType
{
    Pending,
    Paid,
    Processing,
    Shipped,
    Completed,
    Cancelled,
    Refunded
}

public enum OrderPaymentMethodType
{
    Card,
    PayPal,
    Crypto,
    PlatformCredits
}

public class Order
{
    public int Id { get; set; }

    public OrderStatusType Status { get; set; }
    public decimal Total { get; set; } = 0.00m;
    public decimal DiscountApplied { get; set; } = 0.00m;
    public string Currency { get; set; } = "USD";
    public OrderPaymentMethodType? PaymentMethod { get; set; }
    public string? PaymentReference { get; set; }
    public string? ShippingAddress { get; set; }
    public string? TrackingNumber { get; set; }
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? PaidAt { get; set; } = null;
    public DateTime? ShippedAt { get; set; } = null;

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? ItemsId { get; set; }
    [ForeignKey(nameof(ItemsId))]
    public OrderItem? Items { get; set; }
    public int? CouponId { get; set; }
    [ForeignKey(nameof(CouponId))]
    public Coupon? Coupon { get; set; }
}
