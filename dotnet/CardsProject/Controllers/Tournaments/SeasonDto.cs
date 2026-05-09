namespace CardsProject.Controllers.Tournaments;

public class SeasonDto
{
    public string? Name { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public string? Format { get; set; }
    public bool? IsActive { get; set; }
    public string? RewardDescription { get; set; }
}
