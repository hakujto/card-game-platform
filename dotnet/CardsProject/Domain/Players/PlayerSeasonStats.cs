using CardsProject.Domain.Tournaments;
using System.ComponentModel.DataAnnotations.Schema;

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

public class PlayerSeasonStats
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
        throw new NotImplementedException("win_rate not implemented");
    }

    public void AddPoints(int points)
    {
        throw new NotImplementedException("add_points not implemented");
    }

    public void RecordTournamentWin()
    {
        throw new NotImplementedException("record_tournament_win not implemented");
    }
}
