using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

public enum TournamentRoundStatusType
{
    Pending,
    Active,
    Completed
}

public class TournamentRound : IValidatableObject
{
    public int Id { get; set; }

    public int RoundNumber { get; set; } = 0;
    public TournamentRoundStatusType Status { get; set; }
    public DateTime? StartedAt { get; set; } = null;
    public DateTime? EndedAt { get; set; } = null;
    public int TimeLimitMinutes { get; set; } = 50;

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }

    // Business operations

    public void Start()
    {
        // TODO: implement start
    }

    public void Complete()
    {
        // TODO: implement complete
    }

    public void GeneratePairings()
    {
        // TODO: implement generate_pairings
    }

    public bool IsTimeExpired()
    {
        // TODO: implement is_time_expired
        return default;
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( RoundNumber > 0 ))
            yield return new ValidationResult("Round number must be greater than zero", new[] { nameof(Id) });
        if (!( TimeLimitMinutes > 0 ))
            yield return new ValidationResult("Round time limit must be greater than zero", new[] { nameof(Id) });
    }
}
