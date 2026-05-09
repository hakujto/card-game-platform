using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Cards;

public enum CardAbilityAbilityTypeType
{
    Keyword,
    Activated,
    Triggered,
    Static
}

public enum CardAbilityTimingType
{
    Any,
    Sorcery,
    Instant,
    Combat
}

public class CardAbility
{
    public int Id { get; set; }

    public CardAbilityAbilityTypeType AbilityType { get; set; }
    public string? Keyword { get; set; }
    public string AbilityText { get; set; } = "";
    public CardAbilityTimingType? Timing { get; set; }

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
}
