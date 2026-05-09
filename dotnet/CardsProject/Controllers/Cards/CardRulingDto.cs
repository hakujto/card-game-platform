namespace CardsProject.Controllers.Cards;

public class CardRulingDto
{
    public string? RulingText { get; set; }
    public DateOnly? PublishedAt { get; set; }
    public string? Source { get; set; }
    public int? CardId { get; set; }
}
