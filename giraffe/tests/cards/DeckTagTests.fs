module cards_project.cards.DeckTagTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DeckTagApiTests() =

    [<Fact>]
    member _.``list deck_tag returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_tags")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create deck_tag returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            slug = None
            color = None
        |}
        let! resp = client.PostAsJsonAsync("/api/deck_tags", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get deck_tag not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_tags/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch deck_tag field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/deck_tags/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete deck_tag``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            slug = None
            color = None
        |}
        let! createResp = client.PostAsJsonAsync("/api/deck_tags", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/deck_tags/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }

    [<Fact>]
    member _.``search deck_tag returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_tags?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
