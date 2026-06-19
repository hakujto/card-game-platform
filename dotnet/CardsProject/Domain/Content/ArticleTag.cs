namespace CardsProject.Domain.Content;

public class ArticleTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Slug { get; set; } = "";

    public ICollection<ArticleTagAssignment> ArticleAssignments { get; set; } = new List<ArticleTagAssignment>();

    // Business operations

    public void Rename(string newName)
    {
        // TODO: implement rename
    }

    public int ArticleCount()
    {
        // TODO: implement article_count
        return default;
    }
}
