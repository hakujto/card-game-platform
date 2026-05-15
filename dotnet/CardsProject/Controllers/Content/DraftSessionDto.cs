namespace CardsProject.Controllers.Content;

public class DraftSessionDto
{
    public string? Status { get; set; }
    public string? DraftType { get; set; }
    public int? Seats { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int? CardSetId { get; set; }
}
