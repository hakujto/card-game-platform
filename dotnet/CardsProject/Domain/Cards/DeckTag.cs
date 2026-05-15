namespace CardsProject.Domain.Cards;

public class DeckTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Color { get; set; }

    // Business operations

    public void Rename(string newName)
    {
        throw new NotImplementedException("rename not implemented");
    }

    public void MergeInto(int targetTagId)
    {
        throw new NotImplementedException("merge_into not implemented");
    }
}
