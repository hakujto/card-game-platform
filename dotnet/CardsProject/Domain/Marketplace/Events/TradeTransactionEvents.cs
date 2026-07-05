namespace CardsProject.Domain.Marketplace.Events;

public sealed record TransactionCompleted(
    int TransactionId,
    int BuyerId,
    int SellerId,
    decimal FinalPrice,
    DateTime CompletedAt
);
