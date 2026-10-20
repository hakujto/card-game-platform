module cards_project.content.DraftPickTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DraftPickApiTests() =

    [<Fact>]
    member _.``list draft_pick returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_picks")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get draft_pick not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_picks/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
