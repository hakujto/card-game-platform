namespace CardsProject.Controllers.Tournaments;

public class TournamentDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Format { get; set; }
    public string? TournamentType { get; set; }
    public string? Status { get; set; }
    public int? MaxPlayers { get; set; }
    public decimal? EntryFee { get; set; }
    public decimal? PrizePool { get; set; }
    public DateTime? StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public bool? IsOnline { get; set; }
    public string? Location { get; set; }
    public string? RulesText { get; set; }
    public DateTime? CreatedAt { get; set; }
    public int? SeasonId { get; set; }
    public int? OrganizerId { get; set; }
    public int? RegistrationsId { get; set; }
    public int? RoundsId { get; set; }
    public int? PrizesId { get; set; }
}
