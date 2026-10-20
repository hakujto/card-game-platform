module cards_project.content.ArticleTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type ArticleApiTests() =

    [<Fact>]
    member _.``list article returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/articles")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create article returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            title = "test"
            slug = "test-slug"
            body = "test"
            excerpt = None
            cover_image_url = None
            status = "Draft"
            article_type = "Guide"
            language = "EN"
            view_count = 42
            likes_count = 42
            total_views_alltime = 42L
            is_featured = false
            published_at = None
            author_id = 1L
            featured_deck_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/articles", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get article not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/articles/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch article field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| title = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/articles/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search article returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/articles?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
