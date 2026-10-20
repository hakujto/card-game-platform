module cards_project.tournaments.TournamentRoundTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TournamentRoundApiTests() =

    [<Fact>]
    member _.``list tournament_round returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_rounds")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create tournament_round returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            round_number = 42
            status = "Pending"
            started_at = None
            ended_at = None
            time_limit_minutes = 42
            tournament_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/tournament_rounds", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get tournament_round not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_rounds/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
