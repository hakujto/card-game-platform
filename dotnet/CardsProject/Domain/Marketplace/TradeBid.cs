using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public class TradeBid
{
    public int Id { get; set; }

    public decimal Amount { get; set; } = 0.00m;
    public DateTime? PlacedAt { get; set; } = null;
    public bool IsWinning { get; set; } = false;

    public int? ListingId { get; set; }
    [ForeignKey(nameof(ListingId))]
    public Tradelisting? Listing { get; set; }
    public int? BidderId { get; set; }
    [ForeignKey(nameof(BidderId))]
    public Player? Bidder { get; set; }
}
