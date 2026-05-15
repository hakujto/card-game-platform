using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Players;

public class CraftingRecipe : IValidatableObject
{
    public int Id { get; set; }

    public int DustCost { get; set; } = 0;
    public bool IsAvailable { get; set; } = true;

    public int? ResultCardId { get; set; }
    [ForeignKey(nameof(ResultCardId))]
    public Card? ResultCard { get; set; }

    public ICollection<Card> RequiredCards { get; set; } = new List<Card>();

    // Business operations

    public void Disable()
    {
        throw new NotImplementedException("disable not implemented");
    }

    public void Enable()
    {
        throw new NotImplementedException("enable not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( DustCost > 0 ))
            yield return new ValidationResult("Crafting recipe must have a dust cost greater than zero", new[] { nameof(Id) });
    }
}
