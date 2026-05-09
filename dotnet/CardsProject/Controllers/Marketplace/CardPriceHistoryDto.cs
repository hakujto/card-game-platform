namespace CardsProject.Controllers.Marketplace;

public class CardPriceHistoryDto
{
    public DateOnly? PriceDate { get; set; }
    public decimal? AvgPrice { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public int? Volume { get; set; }
    public bool? Foil { get; set; }
    public int? CardId { get; set; }
}
