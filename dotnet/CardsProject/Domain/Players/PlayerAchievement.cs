using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Players;

public class PlayerAchievement : IValidatableObject
{
    public int Id { get; set; }

    public DateTime? EarnedAt { get; set; } = null;
    public int Progress { get; set; } = 0;
    public bool IsCompleted { get; set; } = false;

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? AchievementId { get; set; }
    [ForeignKey(nameof(AchievementId))]
    public Achievement? Achievement { get; set; }

    // Business operations

    public void IncrementProgress(int amount)
    {
        throw new NotImplementedException("increment_progress not implemented");
    }

    public void Complete()
    {
        throw new NotImplementedException("complete not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Progress >= 0 ))
            yield return new ValidationResult("Achievement progress must not be negative", new[] { nameof(Id) });
    }
}
