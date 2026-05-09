using System.ComponentModel.DataAnnotations.Schema;

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

public class Card
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
    public int? RulingsId { get; set; }
    [ForeignKey(nameof(RulingsId))]
    public CardRuling? Rulings { get; set; }
    public int? AbilitiesId { get; set; }
    [ForeignKey(nameof(AbilitiesId))]
    public CardAbility? Abilities { get; set; }
}
