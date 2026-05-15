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

    // Business operations

    public void Activate()
    {
        throw new NotImplementedException("activate not implemented");
    }

    public void Deactivate()
    {
        throw new NotImplementedException("deactivate not implemented");
    }

    public void FinalizeRewards()
    {
        throw new NotImplementedException("finalize_rewards not implemented");
    }

    public bool IsOngoing()
    {
        throw new NotImplementedException("is_ongoing not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (EndDate == null || (StartDate != null && EndDate > StartDate)) ))
            yield return new ValidationResult("Season end date must be after start date", new[] { nameof(Id) });
    }
}
