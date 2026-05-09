namespace CardsProject.Controllers.Content;

public class DraftPickDto
{
    public int? PickNumber { get; set; }
    public int? PackNumber { get; set; }
    public DateTime? PickedAt { get; set; }
    public int? ParticipantId { get; set; }
    public int? CardId { get; set; }
}
