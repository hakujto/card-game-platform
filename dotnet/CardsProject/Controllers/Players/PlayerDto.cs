namespace CardsProject.Controllers.Players;

public class PlayerDto
{
    public string? DisplayName { get; set; }
    public string? Rank { get; set; }
    public int? Rating { get; set; }
    public int? PeakRating { get; set; }
    public string? Bio { get; set; }
    public string? CountryCode { get; set; }
    public string? AvatarUrl { get; set; }
    public string? PreferredFormat { get; set; }
    public bool? IsVerified { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? LastActiveAt { get; set; }
    public string? UserId { get; set; }
    public int? SeasonStatsId { get; set; }
}
