namespace CardsProject.Controllers.Tournaments;

public class TournamentDto
{
    public Guid? PublicId { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public string? Status { get; set; }
    public string? BracketData { get; set; }
    public string? Format { get; set; }
    public string? TournamentType { get; set; }
    public int? MaxPlayers { get; set; }
    public decimal? EntryFee { get; set; }
    public decimal? PrizePool { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("startTime")]
    public DateTime? StartTime { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("endTime")]
    public DateTime? EndTime { get; set; }
    public bool? IsOnline { get; set; }
    public string? Location { get; set; }
    public string? RulesText { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    public int? SeasonId { get; set; }
    public int? OrganizerId { get; set; }
}
