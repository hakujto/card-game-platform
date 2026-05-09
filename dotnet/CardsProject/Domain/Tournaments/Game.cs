using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum GameWinnerSideType
{
    Player1,
    Player2,
    Draw
}

public enum GameEndedByType
{
    Normal,
    Timeout,
    Concession,
    DrawOffer
}

public class Game
{
    public int Id { get; set; }

    public int GameNumber { get; set; } = 0;
    public GameWinnerSideType? WinnerSide { get; set; }
    public int? TurnsPlayed { get; set; } = null;
    public int? DurationSeconds { get; set; } = null;
    public GameEndedByType? EndedBy { get; set; }
    public string? ReplayUrl { get; set; }

    public int? MatchId { get; set; }
    [ForeignKey(nameof(MatchId))]
    public Match? Match { get; set; }
    public int? WinnerId { get; set; }
    [ForeignKey(nameof(WinnerId))]
    public Player? Winner { get; set; }
}
