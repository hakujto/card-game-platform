using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Cards;

public enum CardSetSetTypeType
{
    Core,
    Expansion,
    Supplemental,
    Masters,
    Draft
}

public class CardSet : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Code { get; set; } = "";
    public DateOnly? ReleaseDate { get; set; } = null;
    public DateOnly? RotationDate { get; set; } = null;
    public CardSetSetTypeType SetType { get; set; }
    public int TotalCards { get; set; } = 0;
    public bool IsRotated { get; set; } = false;
    public string? Description { get; set; }
    public string? LogoUrl { get; set; }

    // Business operations

    public bool IsLegalInStandard()
    {
        // TODO: implement is_legal_in_standard
        return default;
    }

    public bool IsLegalInFormat(string format)
    {
        // TODO: implement is_legal_in_format
        return default;
    }

    public int CardCountByRarity(string rarity)
    {
        // TODO: implement card_count_by_rarity
        return default;
    }

    public void RotateOut()
    {
        // TODO: implement rotate_out
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( TotalCards > 0 ))
            yield return new ValidationResult("Card set must have at least one card", new[] { nameof(Id) });
    }
}
