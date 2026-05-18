using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

public enum TournamentPrizePrizeTypeType
{
    Currency,
    Cards,
    BoosterPacks,
    Trophy,
    SeasonPoints,
    Mixed
}

public class TournamentPrize : IValidatableObject
{
    public int Id { get; set; }

    public int PlacementFrom { get; set; } = 0;
    public int PlacementTo { get; set; } = 0;
    public TournamentPrizePrizeTypeType PrizeType { get; set; }
    public decimal Amount { get; set; } = 0.00m;
    public string? Description { get; set; }
    public int? PacksCount { get; set; } = null;
    public int SeasonPoints { get; set; } = 0;

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }

    // Business operations

    public bool AppliesToPlacement(int placement)
    {
        throw new NotImplementedException("applies_to_placement not implemented");
    }

    public void AwardToPlayer(int playerId)
    {
        throw new NotImplementedException("award_to_player not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( PlacementTo >= PlacementFrom ))
            yield return new ValidationResult("placement_to must be greater than or equal to placement_from", new[] { nameof(Id) });
        if (!( PlacementFrom > 0 ))
            yield return new ValidationResult("placement_from must be greater than zero", new[] { nameof(Id) });
        if (!( Amount >= 0m ))
            yield return new ValidationResult("Prize amount must not be negative", new[] { nameof(Id) });
    }
}
