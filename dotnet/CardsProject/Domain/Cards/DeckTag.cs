namespace CardsProject.Domain.Cards;

public class DeckTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Color { get; set; }

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
