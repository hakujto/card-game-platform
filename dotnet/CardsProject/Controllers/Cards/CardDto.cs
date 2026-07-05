namespace CardsProject.Controllers.Cards;

public class CardDto
{
    public Guid? PublicId { get; set; }
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
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public bool? IsBanned { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public bool? IsRestricted { get; set; }
    public int? PowerLevel { get; set; }
    public string? Metadata { get; set; }
    public long? TotalCopiesInCirculation { get; set; }
    public int? SetId { get; set; }
}
