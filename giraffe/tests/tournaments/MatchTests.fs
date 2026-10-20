module cards_project.tournaments.MatchTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type MatchApiTests() =

    [<Fact>]
    member _.``list match returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/matches")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create match returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            table_number = None
            status = "Pending"
            player1_wins = 1
            player2_wins = 1
            started_at = None
            ended_at = None
            result_notes = None
            round_id = 1L
            player1_id = 1L
            player2_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/matches", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get match not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/matches/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
