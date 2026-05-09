using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum MatchStatusType
{
    Pending,
    Active,
    Completed,
    BYE,
    Draw
}

public class Match
{
    public int Id { get; set; }

    public int? TableNumber { get; set; } = null;
    public MatchStatusType Status { get; set; }
    public int Player1Wins { get; set; } = 0;
    public int Player2Wins { get; set; } = 0;
    public DateTime? StartedAt { get; set; } = null;
    public DateTime? EndedAt { get; set; } = null;
    public string? ResultNotes { get; set; }

    public int? RoundId { get; set; }
    [ForeignKey(nameof(RoundId))]
    public TournamentRound? Round { get; set; }
    public int? Player1Id { get; set; }
    [ForeignKey(nameof(Player1Id))]
    public Player? Player1 { get; set; }
    public int? Player2Id { get; set; }
    [ForeignKey(nameof(Player2Id))]
    public Player? Player2 { get; set; }
    public int? GamesId { get; set; }
    [ForeignKey(nameof(GamesId))]
    public Game? Games { get; set; }
}
