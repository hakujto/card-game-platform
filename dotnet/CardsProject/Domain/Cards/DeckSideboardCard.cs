using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Cards;

public class DeckSideboardCard : IValidatableObject
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

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Quantity >= 1 && Quantity <= 4 ))
            yield return new ValidationResult("Sideboard card quantity must be between 1 and 4 copies", new[] { nameof(Id) });
    }
}
