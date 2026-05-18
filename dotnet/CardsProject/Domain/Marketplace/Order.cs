using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

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

public class Order : IValidatableObject
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
    public int? CouponId { get; set; }
    [ForeignKey(nameof(CouponId))]
    public Coupon? Coupon { get; set; }

    // Business operations

    public void Cancel()
    {
        throw new NotImplementedException("cancel not implemented");
    }

    public bool Pay(string paymentRef)
    {
        throw new NotImplementedException("pay not implemented");
    }

    public decimal CalculateTotal()
    {
        throw new NotImplementedException("calculate_total not implemented");
    }

    public decimal ApplyDiscount(int percent)
    {
        throw new NotImplementedException("apply_discount not implemented");
    }

    public void Refund()
    {
        throw new NotImplementedException("refund not implemented");
    }

    public void NotifyShipped()
    {
        throw new NotImplementedException("notify_shipped not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Total >= 0m ))
            yield return new ValidationResult("Order total must not be negative", new[] { nameof(Id) });
        if (!( DiscountApplied <= Total ))
            yield return new ValidationResult("Discount applied cannot exceed order total", new[] { nameof(Id) });
    }
}
