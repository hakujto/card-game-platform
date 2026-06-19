using CardsProject.Domain.Players;
using CardsProject.Domain.Content;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Tournaments;

public enum TournamentStatusType
{
    Draft,
    Registration,
    Ongoing,
    Completed,
    Cancelled
}

public enum TournamentFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public enum TournamentTournamentTypeType
{
    Swiss,
    SingleElimination,
    DoubleElimination,
    RoundRobin
}

public class Tournament : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public TournamentStatusType Status { get; set; }
    public TournamentFormatType Format { get; set; }
    public TournamentTournamentTypeType TournamentType { get; set; }
    public int MaxPlayers { get; set; } = 0;
    public decimal EntryFee { get; set; } = 0.00m;
    public decimal PrizePool { get; set; } = 0.00m;
    [JsonPropertyName("startTime")]
    public DateTime? StartTime { get; set; } = null;
    [JsonPropertyName("endTime")]
    public DateTime? EndTime { get; set; } = null;
    public bool IsOnline { get; set; } = true;
    public string? Location { get; set; }
    public string? RulesText { get; set; }
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;

    public int? SeasonId { get; set; }
    [ForeignKey(nameof(SeasonId))]
    public Season? Season { get; set; }
    public int? OrganizerId { get; set; }
    [ForeignKey(nameof(OrganizerId))]
    public Player? Organizer { get; set; }

    public ICollection<TournamentJudge> JudgeAssignments { get; set; } = new List<TournamentJudge>();
    public ICollection<TournamentRegistration> Registrations { get; set; } = new List<TournamentRegistration>();
    public ICollection<TournamentRound> Rounds { get; set; } = new List<TournamentRound>();
    public ICollection<TournamentPrize> Prizes { get; set; } = new List<TournamentPrize>();
    public ICollection<CardsProject.Domain.Content.Stream> Streams { get; set; } = new List<CardsProject.Domain.Content.Stream>();

    // Business operations

    public void Start()
    {
        // TODO: implement start
    }

    public void Cancel()
    {
        // TODO: implement cancel
    }

    public void Complete()
    {
        // TODO: implement complete
    }

    public void GenerateRound()
    {
        // TODO: implement generate_round
    }

    public decimal CalculatePrizeDistribution()
    {
        // TODO: implement calculate_prize_distribution
        return default;
    }

    public void RegisterPlayer(int playerId, int deckId)
    {
        // TODO: implement register_player
    }

    public bool IsFull()
    {
        // TODO: implement is_full
        return default;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<TournamentStatusType, TournamentStatusType[]> AllowedTransitions = new()
    {
        [TournamentStatusType.Draft] = new[] { TournamentStatusType.Registration },
        [TournamentStatusType.Registration] = new[] { TournamentStatusType.Ongoing, TournamentStatusType.Cancelled },
        [TournamentStatusType.Ongoing] = new[] { TournamentStatusType.Completed, TournamentStatusType.Cancelled }
    };

    public void AssertTransition(TournamentStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( MaxPlayers >= 2 && MaxPlayers <= 512 ))
            yield return new ValidationResult("Tournament must allow between 2 and 512 players", new[] { nameof(Id) });
        if (!( EntryFee >= 0m ))
            yield return new ValidationResult("Entry fee must not be negative", new[] { nameof(Id) });
        if (!( PrizePool >= 0m ))
            yield return new ValidationResult("Prize pool must not be negative", new[] { nameof(Id) });
    }

    // ── Lifecycle hooks (call from AppDbContext.SaveChangesAsync override) ───
    public void SyncSeasonStats()
    {
        // TODO: implement sync_season_stats
    }
    public void PreventDeleteIfOngoing()
    {
        // TODO: implement prevent_delete_if_ongoing
    }
}
