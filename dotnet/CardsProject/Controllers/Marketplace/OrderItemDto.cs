namespace CardsProject.Controllers.Marketplace;

public class OrderItemDto
{
    public int? Quantity { get; set; }
    public decimal? PriceAtPurchase { get; set; }
    public bool? Foil { get; set; }
    public int? OrderId { get; set; }
    public int? ProductId { get; set; }
}
