using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Cards;

public class DeckCard
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 1;
    public bool IsCommander { get; set; } = false;

    public int? DeckId { get; set; }
    [ForeignKey(nameof(DeckId))]
    public Deck? Deck { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
}
