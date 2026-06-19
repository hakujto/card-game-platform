using CardsProject.Domain.Players;
using CardsProject.Domain.Marketplace;
using CardsProject.Domain.Content;
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

    public ICollection<CardRuling> Rulings { get; set; } = new List<CardRuling>();
    public ICollection<CardAbility> Abilities { get; set; } = new List<CardAbility>();
    public ICollection<DeckCard> DeckCards { get; set; } = new List<DeckCard>();
    public ICollection<DeckSideboardCard> SideboardDecks { get; set; } = new List<DeckSideboardCard>();
    public ICollection<CardsProject.Domain.Players.PlayerCollection> PlayerCollections { get; set; } = new List<CardsProject.Domain.Players.PlayerCollection>();
    public ICollection<CardsProject.Domain.Players.CraftingRecipe> CraftingRecipes { get; set; } = new List<CardsProject.Domain.Players.CraftingRecipe>();
    public ICollection<CardsProject.Domain.Players.CraftingIngredient> UsedInRecipes { get; set; } = new List<CardsProject.Domain.Players.CraftingIngredient>();
    public CardsProject.Domain.Marketplace.Product? ShopProduct { get; set; }
    public ICollection<CardsProject.Domain.Marketplace.TradeListing> TradeListings { get; set; } = new List<CardsProject.Domain.Marketplace.TradeListing>();
    public ICollection<CardsProject.Domain.Marketplace.CardPriceHistory> PriceHistory { get; set; } = new List<CardsProject.Domain.Marketplace.CardPriceHistory>();
    public ICollection<CardsProject.Domain.Content.DraftPick> DraftPicks { get; set; } = new List<CardsProject.Domain.Content.DraftPick>();

    // Business operations

    public void Ban()
    {
        // TODO: implement ban
    }

    public void Unban()
    {
        // TODO: implement unban
    }

    public void Restrict()
    {
        // TODO: implement restrict
    }

    public void Unrestrict()
    {
        // TODO: implement unrestrict
    }

    public decimal CalculateValue()
    {
        // TODO: implement calculate_value
        return default;
    }

    public decimal ApplyRarityBonus(int multiplier)
    {
        // TODO: implement apply_rarity_bonus
        return default;
    }

    public bool IsLegalInFormat(string format)
    {
        // TODO: implement is_legal_in_format
        return default;
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

    // ── Lifecycle hooks (call from AppDbContext.SaveChangesAsync override) ───
    public void ValidateLegality()
    {
        // TODO: implement validate_legality
    }
    public void ValidateNotInUse()
    {
        // TODO: implement validate_not_in_use
    }
}
