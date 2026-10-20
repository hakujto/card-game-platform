module cards_project.content.DraftSessionTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DraftSessionApiTests() =

    [<Fact>]
    member _.``list draft_session returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_sessions")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create draft_session returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "WaitingForPlayers"
            draft_type = "Booster"
            pack_contents = None
            seats = 2
            time_per_pick_seconds = 42
            completed_at = None
            card_set_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/draft_sessions", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get draft_session not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_sessions/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
