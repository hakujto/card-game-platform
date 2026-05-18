using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Players;

public enum AchievementRarityType
{
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary
}

public class Achievement : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string? IconUrl { get; set; }
    public int Points { get; set; } = 10;
    public AchievementRarityType Rarity { get; set; }
    public bool IsHidden { get; set; } = false;

    // Business operations

    public int PointValue(int multiplier)
    {
        throw new NotImplementedException("point_value not implemented");
    }

    public void Reveal()
    {
        throw new NotImplementedException("reveal not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Points > 0 ))
            yield return new ValidationResult("Achievement must award at least one point", new[] { nameof(Id) });
    }
}
