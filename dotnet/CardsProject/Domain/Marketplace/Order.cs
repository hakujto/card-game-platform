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
        // TODO: implement cancel
    }

    public bool Pay(string paymentRef)
    {
        // TODO: implement pay
        return default;
    }

    public bool ProcessPayment()
    {
        // TODO: implement process_payment
        return default;
    }

    public decimal CalculateTotal()
    {
        // TODO: implement calculate_total
        return default;
    }

    public decimal ApplyDiscount(int percent)
    {
        // TODO: implement apply_discount
        return default;
    }

    public void Refund()
    {
        // TODO: implement refund
    }

    public void NotifyShipped()
    {
        // TODO: implement notify_shipped
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<OrderStatusType, OrderStatusType[]> AllowedTransitions = new()
    {
        [OrderStatusType.Pending] = new[] { OrderStatusType.Paid, OrderStatusType.Cancelled },
        [OrderStatusType.Paid] = new[] { OrderStatusType.Processing, OrderStatusType.Cancelled },
        [OrderStatusType.Processing] = new[] { OrderStatusType.Shipped },
        [OrderStatusType.Shipped] = new[] { OrderStatusType.Completed },
        [OrderStatusType.Completed] = new[] { OrderStatusType.Refunded }
    };

    public void AssertTransition(OrderStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
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
