using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Tournaments;

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

public enum TournamentStatusType
{
    Draft,
    Registration,
    Ongoing,
    Completed,
    Cancelled
}

public class Tournament : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public TournamentFormatType Format { get; set; }
    public TournamentTournamentTypeType TournamentType { get; set; }
    public TournamentStatusType Status { get; set; }
    public int MaxPlayers { get; set; } = 0;
    public decimal EntryFee { get; set; } = 0.00m;
    public decimal PrizePool { get; set; } = 0.00m;
    public DateTime? StartTime { get; set; } = null;
    public DateTime? EndTime { get; set; } = null;
    public bool IsOnline { get; set; } = true;
    public string? Location { get; set; }
    public string? RulesText { get; set; }
    public DateTime? CreatedAt { get; set; } = null;

    public int? SeasonId { get; set; }
    [ForeignKey(nameof(SeasonId))]
    public Season? Season { get; set; }
    public int? OrganizerId { get; set; }
    [ForeignKey(nameof(OrganizerId))]
    public Player? Organizer { get; set; }

    public ICollection<Player> Judges { get; set; } = new List<Player>();

    // Business operations

    public void Start()
    {
        throw new NotImplementedException("start not implemented");
    }

    public void Cancel()
    {
        throw new NotImplementedException("cancel not implemented");
    }

    public void Complete()
    {
        throw new NotImplementedException("complete not implemented");
    }

    public void GenerateRound()
    {
        throw new NotImplementedException("generate_round not implemented");
    }

    public decimal CalculatePrizeDistribution()
    {
        throw new NotImplementedException("calculate_prize_distribution not implemented");
    }

    public bool IsFull()
    {
        throw new NotImplementedException("is_full not implemented");
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
}
