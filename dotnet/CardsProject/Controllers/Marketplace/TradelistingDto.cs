namespace CardsProject.Controllers.Marketplace;

public class TradeListingDto
{
    public string? Status { get; set; }
    public string? ListingType { get; set; }
    public decimal? AskingPrice { get; set; }
    public decimal? AuctionStartPrice { get; set; }
    public decimal? AuctionCurrentBid { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("auctionEndTime")]
    public DateTime? AuctionEndTime { get; set; }
    public bool? Foil { get; set; }
    public string? Condition { get; set; }
    public int? Quantity { get; set; }
    public string? Description { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("expiresAt")]
    public DateTime? ExpiresAt { get; set; }
    public int? SellerId { get; set; }
    public int? CardId { get; set; }
}
