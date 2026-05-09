namespace CardsProject.Controllers.Tournaments;

public class AwardedPrizeDto
{
    public int? FinalPlacement { get; set; }
    public DateTime? AwardedAt { get; set; }
    public bool? Claimed { get; set; }
    public DateTime? ClaimedAt { get; set; }
    public int? PrizeId { get; set; }
    public int? PlayerId { get; set; }
}
