using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum ProductProductTypeType
{
    SingleCard,
    BoosterPack,
    Bundle,
    PreconstructedDeck,
    Accessory
}

public class Product
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public ProductProductTypeType ProductType { get; set; }
    public decimal Price { get; set; } = 0.00m;
    public int Stock { get; set; } = 0;
    public bool Active { get; set; } = true;
    public int DiscountPercent { get; set; } = 0;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public bool Featured { get; set; } = false;

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
    public int? CardSetId { get; set; }
    [ForeignKey(nameof(CardSetId))]
    public CardSet? CardSet { get; set; }
}
