module cards_project.content.DraftParticipantTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DraftParticipantApiTests() =

    [<Fact>]
    member _.``list draft_participant returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_participants")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create draft_participant returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            seat_number = 42
            joined_at = "2024-01-01T00:00:00"
            session_id = 1L
            player_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/draft_participants", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get draft_participant not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/draft_participants/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
