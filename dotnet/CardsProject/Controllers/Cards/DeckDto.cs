namespace CardsProject.Controllers.Cards;

public class DeckDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Format { get; set; }
    public bool? IsPublic { get; set; }
    public bool? IsTournamentLegal { get; set; }
    public string? Archetype { get; set; }
    public int? Wins { get; set; }
    public int? Losses { get; set; }
    public int? Draws { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int? PlayerId { get; set; }
}
