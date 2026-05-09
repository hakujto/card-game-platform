namespace CardsProject.Controllers.Players;

public class PlayerCollectionDto
{
    public int? Quantity { get; set; }
    public bool? Foil { get; set; }
    public string? Condition { get; set; }
    public DateTime? AcquiredAt { get; set; }
    public string? AcquiredVia { get; set; }
    public int? PlayerId { get; set; }
    public int? CardId { get; set; }
}
