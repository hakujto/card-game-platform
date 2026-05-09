namespace CardsProject.Domain.Cards;

public enum CardSetSetTypeType
{
    Core,
    Expansion,
    Supplemental,
    Masters,
    Draft
}

public class CardSet
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Code { get; set; } = "";
    public DateOnly? ReleaseDate { get; set; } = null;
    public CardSetSetTypeType SetType { get; set; }
    public int TotalCards { get; set; } = 0;
    public string? Description { get; set; }
    public string? LogoUrl { get; set; }
}
