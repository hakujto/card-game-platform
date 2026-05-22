namespace CardsProject.Controllers.Players;

public class PlayerAchievementDto
{
    [System.Text.Json.Serialization.JsonPropertyName("earnedAt")]
    public DateTime? EarnedAt { get; set; }
    public int? Progress { get; set; }
    public bool? IsCompleted { get; set; }
    public int? PlayerId { get; set; }
    public int? AchievementId { get; set; }
}
