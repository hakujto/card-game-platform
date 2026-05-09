using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Players;

public class PlayerAchievement
{
    public int Id { get; set; }

    public DateTime? EarnedAt { get; set; } = null;
    public int Progress { get; set; } = 0;
    public bool IsCompleted { get; set; } = false;

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? AchievementId { get; set; }
    [ForeignKey(nameof(AchievementId))]
    public Achievement? Achievement { get; set; }
}
