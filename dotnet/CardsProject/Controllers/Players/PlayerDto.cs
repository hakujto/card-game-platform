namespace CardsProject.Controllers.Players;

public class PlayerDto
{
    public Guid? PublicId { get; set; }
    public string? DisplayName { get; set; }
    public string? Rank { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? Rating { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? PeakRating { get; set; }
    public string? Bio { get; set; }
    public string? CountryCode { get; set; }
    public string? AvatarUrl { get; set; }
    public string? PreferredFormat { get; set; }
    public string? ContactEmail { get; set; }
    public double? WinRateCached { get; set; }
    public bool? IsVerified { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("lastActiveAt")]
    public DateTime? LastActiveAt { get; set; }
    public string? UserId { get; set; }
}
