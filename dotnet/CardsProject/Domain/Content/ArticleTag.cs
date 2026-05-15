namespace CardsProject.Domain.Content;

public class ArticleTag
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string Slug { get; set; } = "";

    // Business operations

    public void Rename(string newName)
    {
        throw new NotImplementedException("rename not implemented");
    }

    public int ArticleCount()
    {
        throw new NotImplementedException("article_count not implemented");
    }
}
