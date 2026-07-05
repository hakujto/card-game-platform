namespace CardsProject.Domain.Marketplace.Events;

public sealed record OrderPaid(
    int OrderId,
    int PlayerId,
    decimal Total,
    string PaymentMethod,
    DateTime PaidAt
);

public sealed record OrderShipped(
    int OrderId,
    string TrackingNumber,
    DateTime ShippedAt
);

public sealed record OrderRefunded(
    int OrderId,
    DateTime RefundedAt
);
