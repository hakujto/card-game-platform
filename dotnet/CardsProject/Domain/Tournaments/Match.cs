using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

public enum MatchStatusType
{
    Pending,
    Active,
    Completed,
    BYE,
    Draw
}

public class Match : IValidatableObject
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

    // Business operations

    public void RecordResult(int p1Wins, int p2Wins)
    {
        throw new NotImplementedException("record_result not implemented");
    }

    public bool DetermineWinner()
    {
        throw new NotImplementedException("determine_winner not implemented");
    }

    public void Concede(int playerId)
    {
        throw new NotImplementedException("concede not implemented");
    }

    public void Draw()
    {
        throw new NotImplementedException("draw not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( (Player1Wins >= 0 && Player2Wins >= 0) ))
            yield return new ValidationResult("Win counts must not be negative", new[] { nameof(Id) });
        if (!( (Player1Wins >= 0 && Player1Wins <= 2 && Player2Wins >= 0 && Player2Wins <= 2) ))
            yield return new ValidationResult("Win counts cannot exceed 2 in a best-of-3 match", new[] { nameof(Id) });
    }
}
