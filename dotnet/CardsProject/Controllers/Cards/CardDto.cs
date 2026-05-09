namespace CardsProject.Controllers.Cards;

public class CardDto
{
    public string? Name { get; set; }
    public string? CardType { get; set; }
    public string? Rarity { get; set; }
    public int? ManaCost { get; set; }
    public string? ManaColors { get; set; }
    public int? Attack { get; set; }
    public int? Defense { get; set; }
    public int? Loyalty { get; set; }
    public string? Description { get; set; }
    public string? FlavorText { get; set; }
    public string? ImageUrl { get; set; }
    public string? ArtistName { get; set; }
    public string? LegalFormats { get; set; }
    public bool? IsBanned { get; set; }
    public bool? IsRestricted { get; set; }
    public int? PowerLevel { get; set; }
    public int? SetId { get; set; }
    public int? RulingsId { get; set; }
    public int? AbilitiesId { get; set; }
}
