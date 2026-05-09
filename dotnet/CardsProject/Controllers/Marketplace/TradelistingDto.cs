namespace CardsProject.Controllers.Marketplace;

public class TradelistingDto
{
    public string? ListingType { get; set; }
    public decimal? AskingPrice { get; set; }
    public decimal? AuctionStartPrice { get; set; }
    public decimal? AuctionCurrentBid { get; set; }
    public DateTime? AuctionEndTime { get; set; }
    public bool? Foil { get; set; }
    public string? Condition { get; set; }
    public int? Quantity { get; set; }
    public string? Status { get; set; }
    public string? Description { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public int? SellerId { get; set; }
    public int? CardId { get; set; }
    public int? BidsId { get; set; }
}
