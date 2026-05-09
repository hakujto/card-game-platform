namespace CardsProject.Controllers.Cards;

public class CardSetDto
{
    public string? Name { get; set; }
    public string? Code { get; set; }
    public DateOnly? ReleaseDate { get; set; }
    public string? SetType { get; set; }
    public int? TotalCards { get; set; }
    public string? Description { get; set; }
    public string? LogoUrl { get; set; }
}
