using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Content;

public class DraftPick : IValidatableObject
{
    public int Id { get; set; }

    public int PickNumber { get; set; } = 0;
    public int PackNumber { get; set; } = 0;
    public DateTime? PickedAt { get; set; } = null;

    public int? ParticipantId { get; set; }
    [ForeignKey(nameof(ParticipantId))]
    public DraftParticipant? Participant { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public bool IsFirstPick()
    {
        throw new NotImplementedException("is_first_pick not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( PickNumber > 0 ))
            yield return new ValidationResult("Pick number must be greater than zero", new[] { nameof(Id) });
        if (!( PackNumber >= 1 && PackNumber <= 3 ))
            yield return new ValidationResult("Pack number must be between 1 and 3", new[] { nameof(Id) });
    }
}
