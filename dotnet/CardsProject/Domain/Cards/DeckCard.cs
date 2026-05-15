using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Cards;

public class DeckCard : IValidatableObject
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

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Quantity >= 1 && Quantity <= 4 ))
            yield return new ValidationResult("A deck can contain between 1 and 4 copies of a card", new[] { nameof(Id) });
    }
}
