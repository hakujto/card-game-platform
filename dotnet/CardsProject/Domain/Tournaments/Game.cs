using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

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

public class Game : IValidatableObject
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

    // Business operations

    public void RecordWinner(string winnerSide)
    {
        throw new NotImplementedException("record_winner not implemented");
    }

    public decimal DurationMinutes()
    {
        throw new NotImplementedException("duration_minutes not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( GameNumber >= 1 && GameNumber <= 3 ))
            yield return new ValidationResult("Game number must be between 1 and 3 (best-of-3)", new[] { nameof(Id) });
    }
}
