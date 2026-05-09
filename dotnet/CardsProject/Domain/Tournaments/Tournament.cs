using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

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

public class Tournament
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
    public int? RegistrationsId { get; set; }
    [ForeignKey(nameof(RegistrationsId))]
    public TournamentRegistration? Registrations { get; set; }
    public int? RoundsId { get; set; }
    [ForeignKey(nameof(RoundsId))]
    public TournamentRound? Rounds { get; set; }
    public int? PrizesId { get; set; }
    [ForeignKey(nameof(PrizesId))]
    public TournamentPrize? Prizes { get; set; }

    public ICollection<Player> Judges { get; set; } = new List<Player>();
}
