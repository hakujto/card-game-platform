using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public class CardPriceHistory
{
    public int Id { get; set; }

    public DateOnly? PriceDate { get; set; } = null;
    public decimal AvgPrice { get; set; } = 0.00m;
    public decimal MinPrice { get; set; } = 0.00m;
    public decimal MaxPrice { get; set; } = 0.00m;
    public int Volume { get; set; } = 0;
    public bool Foil { get; set; } = false;

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
}
