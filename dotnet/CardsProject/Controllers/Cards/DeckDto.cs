namespace CardsProject.Controllers.Cards;

public class DeckDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Format { get; set; }
    public bool? IsPublic { get; set; }
    public bool? IsTournamentLegal { get; set; }
    public string? Archetype { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? Wins { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? Losses { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? Draws { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("updatedAt")]
    public DateTime? UpdatedAt { get; set; }
    public int? PlayerId { get; set; }
}
