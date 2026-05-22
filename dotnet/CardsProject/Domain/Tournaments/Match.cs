using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

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
    [JsonPropertyName("startedAt")]
    public DateTime? StartedAt { get; set; } = null;
    [JsonPropertyName("endedAt")]
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
        // TODO: implement record_result
    }

    public void FinalizeResult()
    {
        // TODO: implement finalize_result
    }

    public bool DetermineWinner()
    {
        // TODO: implement determine_winner
        return default;
    }

    public void Concede(int playerId)
    {
        // TODO: implement concede
    }

    public void Draw()
    {
        // TODO: implement draw
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<MatchStatusType, MatchStatusType[]> AllowedTransitions = new()
    {
        [MatchStatusType.Pending] = new[] { MatchStatusType.Active, MatchStatusType.BYE },
        [MatchStatusType.Active] = new[] { MatchStatusType.Completed, MatchStatusType.Draw }
    };

    public void AssertTransition(MatchStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
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
