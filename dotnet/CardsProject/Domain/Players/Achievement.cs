namespace CardsProject.Domain.Players;

public enum AchievementRarityType
{
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary
}

public class Achievement
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string? IconUrl { get; set; }
    public int Points { get; set; } = 10;
    public AchievementRarityType Rarity { get; set; }
    public bool IsHidden { get; set; } = false;
}
