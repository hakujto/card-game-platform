using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Cards;

public enum CardCardTypeType
{
    Creature,
    Spell,
    Land,
    Artifact,
    Enchantment,
    Planeswalker
}

public enum CardRarityType
{
    Common,
    Uncommon,
    Rare,
    MythicRare,
    Legendary
}

public enum CardManaColorsType
{
    White,
    Blue,
    Black,
    Red,
    Green,
    Colorless
}

public enum CardLegalFormatsType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public class Card : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public CardCardTypeType CardType { get; set; }
    public CardRarityType Rarity { get; set; }
    public int ManaCost { get; set; } = 0;
    public CardManaColorsType ManaColors { get; set; }
    public int? Attack { get; set; } = null;
    public int? Defense { get; set; } = null;
    public int? Loyalty { get; set; } = null;
    public string Description { get; set; } = "";
    public string? FlavorText { get; set; }
    public string? ImageUrl { get; set; }
    public string? ArtistName { get; set; }
    public CardLegalFormatsType LegalFormats { get; set; }
    public bool IsBanned { get; set; } = false;
    public bool IsRestricted { get; set; } = false;
    public int PowerLevel { get; set; } = 1;

    public int? SetId { get; set; }
    [ForeignKey(nameof(SetId))]
    public CardSet? Set { get; set; }

    // Business operations

    public void Ban()
    {
        throw new NotImplementedException("ban not implemented");
    }

    public void Unban()
    {
        throw new NotImplementedException("unban not implemented");
    }

    public void Restrict()
    {
        throw new NotImplementedException("restrict not implemented");
    }

    public void Unrestrict()
    {
        throw new NotImplementedException("unrestrict not implemented");
    }

    public decimal CalculateValue()
    {
        throw new NotImplementedException("calculate_value not implemented");
    }

    public decimal ApplyRarityBonus(int multiplier)
    {
        throw new NotImplementedException("apply_rarity_bonus not implemented");
    }

    public bool IsLegalInFormat(string format)
    {
        throw new NotImplementedException("is_legal_in_format not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( ManaCost >= 0 && ManaCost <= 20 ))
            yield return new ValidationResult("mana_cost must be between 0 and 20", new[] { nameof(Id) });
        if (!( PowerLevel >= 1 && PowerLevel <= 10 ))
            yield return new ValidationResult("power_level must be between 1 and 10", new[] { nameof(Id) });
        if (!( !((IsBanned == true && IsRestricted == true)) ))
            yield return new ValidationResult("Card cannot be both banned and restricted at the same time", new[] { nameof(Id) });
    }
}
