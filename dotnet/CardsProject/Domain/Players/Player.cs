using CardsProject.Infrastructure;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Players;

public enum PlayerRankType
{
    Bronze,
    Silver,
    Gold,
    Platinum,
    Diamond,
    Master,
    Grandmaster
}

public enum PlayerPreferredFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public class Player
{
    public int Id { get; set; }

    public string DisplayName { get; set; } = "";
    public PlayerRankType Rank { get; set; }
    public int Rating { get; set; } = 1000;
    public int PeakRating { get; set; } = 1000;
    public string? Bio { get; set; }
    public string? CountryCode { get; set; }
    public string? AvatarUrl { get; set; }
    public PlayerPreferredFormatType? PreferredFormat { get; set; }
    public bool IsVerified { get; set; } = false;
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? LastActiveAt { get; set; } = null;

    public string? UserId { get; set; }
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }
    public int? SeasonStatsId { get; set; }
    [ForeignKey(nameof(SeasonStatsId))]
    public PlayerSeasonStats? SeasonStats { get; set; }

    public ICollection<Achievement> Achievements { get; set; } = new List<Achievement>();
    public ICollection<Player> Friends { get; set; } = new List<Player>();
}
