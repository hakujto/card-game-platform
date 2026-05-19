using CardsProject.Domain.Tournaments;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Players;

public enum PlayerSeasonStatsHighestRankType
{
    Bronze,
    Silver,
    Gold,
    Platinum,
    Diamond,
    Master,
    Grandmaster
}

public class PlayerSeasonStats : IValidatableObject
{
    public int Id { get; set; }

    public int Wins { get; set; } = 0;
    public int Losses { get; set; } = 0;
    public int Draws { get; set; } = 0;
    public int TournamentWins { get; set; } = 0;
    public PlayerSeasonStatsHighestRankType? HighestRank { get; set; }
    public int SeasonPoints { get; set; } = 0;

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? SeasonId { get; set; }
    [ForeignKey(nameof(SeasonId))]
    public Season? Season { get; set; }

    // Business operations

    public decimal WinRate()
    {
        // TODO: implement win_rate
        return default;
    }

    public void AddPoints(int points)
    {
        // TODO: implement add_points
    }

    public void RecordTournamentWin()
    {
        // TODO: implement record_tournament_win
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Wins >= 0 ))
            yield return new ValidationResult("Season wins must not be negative", new[] { nameof(Id) });
        if (!( Losses >= 0 ))
            yield return new ValidationResult("Season losses must not be negative", new[] { nameof(Id) });
        if (!( TournamentWins >= 0 ))
            yield return new ValidationResult("Season tournament wins must not be negative", new[] { nameof(Id) });
        if (!( SeasonPoints >= 0 ))
            yield return new ValidationResult("Season points must not be negative", new[] { nameof(Id) });
    }
}
