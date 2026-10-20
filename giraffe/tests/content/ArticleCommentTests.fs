module cards_project.content.ArticleCommentTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type ArticleCommentApiTests() =

    [<Fact>]
    member _.``list article_comment returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/article_comments")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create article_comment returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            body = "test"
            is_hidden = false
            article_id = 1L
            author_id = 1L
            parent_comment_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/article_comments", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get article_comment not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/article_comments/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete article_comment``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            body = "test"
            is_hidden = false
            article_id = 1L
            author_id = 1L
            parent_comment_id = None
        |}
        let! createResp = client.PostAsJsonAsync("/api/article_comments", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/article_comments/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
