namespace CardsProject.Domain.Tournaments;

public enum SeasonFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public class Season
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public DateOnly? StartDate { get; set; } = null;
    public DateOnly? EndDate { get; set; } = null;
    public SeasonFormatType Format { get; set; }
    public bool IsActive { get; set; } = false;
    public string? RewardDescription { get; set; }
}
