namespace CardsProject.Controllers.Tournaments;

public class TournamentPrizeDto
{
    public int? PlacementFrom { get; set; }
    public int? PlacementTo { get; set; }
    public string? PrizeType { get; set; }
    public decimal? Amount { get; set; }
    public string? Description { get; set; }
    public int? PacksCount { get; set; }
    public int? SeasonPoints { get; set; }
    public int? TournamentId { get; set; }
}
