namespace CardsProject.Controllers.Players;

public class AchievementDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? IconUrl { get; set; }
    public int? Points { get; set; }
    public string? Rarity { get; set; }
    public bool? IsHidden { get; set; }
}
