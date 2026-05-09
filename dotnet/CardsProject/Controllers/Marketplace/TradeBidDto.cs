namespace CardsProject.Controllers.Marketplace;

public class TradeBidDto
{
    public decimal? Amount { get; set; }
    public DateTime? PlacedAt { get; set; }
    public bool? IsWinning { get; set; }
    public int? ListingId { get; set; }
    public int? BidderId { get; set; }
}
