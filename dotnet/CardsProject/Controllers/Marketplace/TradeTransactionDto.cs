namespace CardsProject.Controllers.Marketplace;

public class TradeTransactionDto
{
    public decimal? FinalPrice { get; set; }
    public decimal? PlatformFee { get; set; }
    public string? Status { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int? ListingId { get; set; }
    public int? BuyerId { get; set; }
    public int? SellerId { get; set; }
}
