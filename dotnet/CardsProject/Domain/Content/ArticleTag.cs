namespace CardsProject.Domain.Content;

public class ArticleTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Slug { get; set; } = "";

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
