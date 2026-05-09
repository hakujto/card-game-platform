using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum TradeTransactionStatusType
{
    Pending,
    Completed,
    Disputed,
    Refunded
}

public class TradeTransaction
{
    public int Id { get; set; }

    public decimal FinalPrice { get; set; } = 0.00m;
    public decimal PlatformFee { get; set; } = 0.00m;
    public TradeTransactionStatusType Status { get; set; }
    public DateTime? CompletedAt { get; set; } = null;

    public int? ListingId { get; set; }
    [ForeignKey(nameof(ListingId))]
    public Tradelisting? Listing { get; set; }
    public int? BuyerId { get; set; }
    [ForeignKey(nameof(BuyerId))]
    public Player? Buyer { get; set; }
    public int? SellerId { get; set; }
    [ForeignKey(nameof(SellerId))]
    public Player? Seller { get; set; }
}
