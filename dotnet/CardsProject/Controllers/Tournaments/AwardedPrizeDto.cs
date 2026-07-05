namespace CardsProject.Controllers.Tournaments;

public class AwardedPrizeDto
{
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? FinalPlacement { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("awardedAt")]
    public DateTime? AwardedAt { get; set; }
    public bool? Claimed { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("claimedAt")]
    public DateTime? ClaimedAt { get; set; }
    public int? PrizeId { get; set; }
    public int? PlayerId { get; set; }
}
