using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum TournamentPrizePrizeTypeType
{
    Currency,
    Cards,
    BoosterPacks,
    Trophy,
    SeasonPoints,
    Mixed
}

public class TournamentPrize
{
    public int Id { get; set; }

    public int PlacementFrom { get; set; } = 0;
    public int PlacementTo { get; set; } = 0;
    public TournamentPrizePrizeTypeType PrizeType { get; set; }
    public decimal Amount { get; set; } = 0.00m;
    public string? Description { get; set; }
    public int? PacksCount { get; set; } = null;
    public int SeasonPoints { get; set; } = 0;

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }
}
