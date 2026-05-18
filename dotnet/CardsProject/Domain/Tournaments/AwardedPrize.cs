using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

public class AwardedPrize : IValidatableObject
{
    public int Id { get; set; }

    public int FinalPlacement { get; set; } = 0;
    public DateTime? AwardedAt { get; set; } = null;
    public bool Claimed { get; set; } = false;
    public DateTime? ClaimedAt { get; set; } = null;

    public int? PrizeId { get; set; }
    [ForeignKey(nameof(PrizeId))]
    public TournamentPrize? Prize { get; set; }
    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }

    // Business operations

    public void Claim()
    {
        throw new NotImplementedException("claim not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( FinalPlacement > 0 ))
            yield return new ValidationResult("Final placement must be greater than zero", new[] { nameof(Id) });
    }
}
