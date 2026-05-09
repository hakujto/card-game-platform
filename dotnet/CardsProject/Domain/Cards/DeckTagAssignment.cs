using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Cards;

public class DeckTagAssignment
{
    public int Id { get; set; }


    public int? DeckId { get; set; }
    [ForeignKey(nameof(DeckId))]
    public Deck? Deck { get; set; }
    public int? TagId { get; set; }
    [ForeignKey(nameof(TagId))]
    public DeckTag? Tag { get; set; }
}
