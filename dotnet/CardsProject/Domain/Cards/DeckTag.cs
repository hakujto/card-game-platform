namespace CardsProject.Domain.Cards;

public class DeckTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Slug { get; set; }
    public string? Color { get; set; }

    public ICollection<DeckTagAssignment> DeckAssignments { get; set; } = new List<DeckTagAssignment>();

    // Business operations

    public void Rename(string newName)
    {
        // TODO: implement rename
    }

    public void MergeInto(int targetTagId)
    {
        // TODO: implement merge_into
    }
}
