using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

public enum SeasonFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public class Season : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public DateOnly? StartDate { get; set; } = null;
    public DateOnly? EndDate { get; set; } = null;
    public SeasonFormatType Format { get; set; }
    public bool IsActive { get; set; } = false;
    public string? RewardDescription { get; set; }

    public ICollection<CardsProject.Domain.Players.PlayerSeasonStats> PlayerStats { get; set; } = new List<CardsProject.Domain.Players.PlayerSeasonStats>();
    public ICollection<Tournament> Tournaments { get; set; } = new List<Tournament>();

    // Business operations

    public void Activate()
    {
        // TODO: implement activate
    }

    public void Deactivate()
    {
        // TODO: implement deactivate
    }

    public void FinalizeRewards()
    {
        // TODO: implement finalize_rewards
    }

    public bool IsOngoing()
    {
        // TODO: implement is_ongoing
        return default;
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (EndDate == null || (StartDate != null && EndDate > StartDate)) ))
            yield return new ValidationResult("Season end date must be after start date", new[] { nameof(Id) });
    }
}
