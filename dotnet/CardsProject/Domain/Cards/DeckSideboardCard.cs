using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Cards;

public class DeckSideboardCard
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 1;

    public int? DeckId { get; set; }
    [ForeignKey(nameof(DeckId))]
    public Deck? Deck { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public void Increment(int amount)
    {
        throw new NotImplementedException("increment not implemented");
    }

    public void Decrement(int amount)
    {
        throw new NotImplementedException("decrement not implemented");
    }
}
